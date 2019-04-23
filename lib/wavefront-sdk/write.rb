require 'socket'
require_relative 'core/exception'
require_relative 'core/logger'
require_relative 'core/response'
require_relative 'defs/constants'
require_relative 'validators'

HOSTNAME = Socket.gethostname.freeze

module Wavefront
  #
  # This class helps you send points to Wavefront. It is extended by
  # the Write and Report classes, which respectively handle point
  # ingestion by a proxy and directly to the API.
  #
  class Write
    attr_reader :creds, :opts, :writer, :logger

    include Wavefront::Validators

    # Construct an object which gives the user an interface for
    # writing points to Wavefront. The actual writing is handled by
    # a Wavefront::Writer:: subclass.
    #
    # @param creds [Hash] credentials: can contain keys:
    #   proxy [String] the address of the Wavefront proxy. ('wavefront')
    #   port [Integer] the port of the Wavefront proxy
    # @param options [Hash] can contain the following keys:
    #   tags [Hash] point tags which will be applied to every point
    #   noop [Bool] if true, no proxy connection will be made, and
    #     instead of sending the points, they will be printed in
    #     Wavefront wire format.
    #   novalidate [Bool] if true, points will not be validated.
    #     This might make things go marginally quicker if you have
    #     done point validation higher up in the chain. Invalid
    #     points are dropped, logged, and reported in the summary.
    #   verbose [Bool]
    #   debug [Bool]
    #   writer [Symbol, String] the name of the writer class to use.
    #     Defaults to :socket
    #   noauto [Bool] if this is false, #write will automatically
    #     open a connection to Wavefront on each invocation. Set
    #     this to true to manually manage the connection.
    #   chunk_size [Integer] So as not to create unusable metric
    #     payloads, large batches of points will be broken into
    #     chunks. This property controls the number of metrics in a
    #     chunk. Defaults to 1,000.
    #   chunk_pause [Integer] pause this many seconds between
    #     writing chunks. Defaults to zero.
    #
    def initialize(creds = {}, opts = {})
      @opts = setup_options(opts, defaults)
      @creds = creds
      wf_point_tags?(opts[:tags]) if opts[:tags]
      @logger = Wavefront::Logger.new(opts)
      @writer = setup_writer
    end

    def defaults
      { tags:        nil,
        writer:      :socket,
        noop:        false,
        novalidate:  false,
        noauto:      false,
        verbose:     false,
        debug:       false,
        chunk_size:  1000,
        chunk_pause: 0 }
    end

    def setup_options(user, defaults)
      defaults.merge(user)
    end

    # Wrapper to the writer class's #open method. Using this you can
    # manually open a connection and re-use it.
    #
    def open
      writer.open
    end

    # Wrapper to the writer class's #close method.
    #
    def close
      writer.close
    end

    # A wrapper to the writer class's #write method.
    # Writers implement this method differently, Check the
    # appropriate class documentation for @return information etc.
    # The signature is always the same.
    # @return [Boolean] false should any chunk fail
    # @raise any exceptions raised by the writer classes are passed
    #   through
    #
    def write(points = [], openclose = manage_conn, prefix = nil)
      resps = [points].flatten.each_slice(opts[:chunk_size]).map do |chunk|
        resp = writer.write(chunk, openclose, prefix)
        sleep(opts[:chunk_pause])
        resp
      end

      composite_response(resps)
    end

    # Compound the responses of all chunked writes into one. It will
    # be 'ok' only if *everything* passed.
    # @param responses [Array[Wavefront::Response]]
    # @return Wavefront::Response
    #
    def composite_response(responses)
      result = responses.all?(&:ok?) ? 'OK' : 'ERROR'
      summary = { sent: 0, rejected: 0, unsent: 0 }

      %i[sent rejected unsent].each do |k|
        summary[k] = responses.map { |r| r.response[k] }.inject(:+)
      end

      Wavefront::Response.new(
        { status:   { result: result, message: nil, code: nil },
          response: summary.to_h }.to_json, nil
      )
    end

    def manage_conn
      opts[:noauto] ? false : true
    end

    # A wrapper method around #write() which guarantees all points
    # will be sent as deltas. You can still manually prefix any
    # metric with a delta symbol and use #write(), but depending on
    # your use-case, this method may be safer. It's easy to forget
    # the delta.
    #
    # @param points [Array[Hash]] see #write()
    # @param openclose [Bool] see #write()
    #
    def write_delta(points, openclose = manage_conn)
      write(paths_to_deltas(points), openclose)
    end

    # Prefix all paths in a points array (as passed to
    # #write_delta() with a delta symbol
    #
    # @param points [Array[Hash]] see #write()
    # @return [Array[Hash]]
    #
    def paths_to_deltas(points)
      [points].flatten.map { |p| p.tap { p[:path] = DELTA + p[:path] } }
    end

    # Wrapper for the writer class's #send_point method
    # @param point [String] a point description, probably from
    #   #hash_to_wf()
    #
    def send_point(point)
      if opts[:noop]
        logger.log "Would send: #{point}"
        return
      end

      logger.log("Sending: #{point}", :debug)
      writer.send_point(point)
    end

    # Send raw data to a Wavefront proxy, optionally automatically
    # opening and closing the connection. (Or not, if that does not
    # make sense in the context of the writer.)
    #
    # @param points [Array[String]] an array of points in native
    #   Wavefront wire format, as described in
    #   https://community.wavefront.com/docs/DOC-1031. No validation
    #   is performed.
    # @param openclose [Boolean] whether or not to automatically
    #   open a socket to the proxy before sending points, and
    #   afterwards, close it.
    #
    def raw(points, openclose = manage_conn)
      writer.open if openclose && writer.respond_to?(:open)

      begin
        [points].flatten.each { |p| writer.send_point(p) }
      ensure
        writer.close if openclose && writer.respond_to?(:close)
      end
    end

    # The method used to validate the data we wish to write.
    #
    def validation
      :wf_point?
    end

    # Convert a validated point to a string conforming to
    # https://community.wavefront.com/docs/DOC-1031.  No validation
    # is done here.
    #
    # @param point [Hash] a hash describing a point. See #write() for
    #   the format.
    #
    def hash_to_wf(point)
      format('%s %s %s source=%s %s %s',
             *point_array(point)).squeeze(' ').strip
    rescue StandardError
      raise Wavefront::Exception::InvalidPoint
    end

    # Make an array which can be used by #hash_to_wf.
    # @param point [Hash] a hash describing a point. See #write() for
    #   the format.
    # @raise
    #
    def point_array(point)
      [point[:path] || raise,
       point[:value] || raise,
       point.fetch(:ts, nil),
       point.fetch(:source, HOSTNAME),
       point[:tags]&.to_wf_tag,
       opts[:tags]&.to_wf_tag]
    end

    private

    # @return [Object] appropriate subclass of Wavefront::Writer
    # @raise [Wavefront::Exception::UnsupportedWriter] if requested
    #   writer cannot be loaded
    #
    def setup_writer
      writer = opts[:writer].to_s
      require_relative File.join('writers', writer)
      Object.const_get(format('Wavefront::Writer::%s',
                              writer.capitalize)).new(self)
    rescue LoadError
      raise(Wavefront::Exception::UnsupportedWriter, writer)
    end
  end
end
