require 'socket'
require_relative './base'

HOSTNAME = Socket.gethostname.freeze

module Wavefront
  #
  # This class helps you send points to a Wavefront proxy in native
  # format. Usually this is done on port 2878.
  #
  class Write < Base
    attr_reader :sock, :summary

    # Construct an object which allows us to write points to a
    # Wavefront proxy.
    #
    # @param _creds [Hash] dummy parameter for correct method
    #   signature.
    # @param options [Hash] can contain the following keys:
    #   proxy [String] the address of the Wavefront proxy. ('wavefront')
    #   port [Integer] the port of the Wavefront proxy (2878)
    #   tags [Hash] point tags which will be applied to every point
    #   noop [Bool] if true, no proxy connection will be made, and
    #     instead of sending the points, they will be printed in
    #     Wavefront wire format.
    #   novalidate [Bool] if true, points will not be validated.
    #     This might make things go marginally quicker if you have
    #     done point validation higher up in the chain.
    #   verbose [Bool]
    #   debug [Bool]
    #
    def post_initialize(_creds = {}, options = {})
      defaults = { tags:       nil,
                   noop:       false,
                   novalidate: false,
                   verbose:    false,
                   debug:      false }

      @summary = { sent: 0, rejected: 0, unsent: 0 }
      @opts = setup_options(options, defaults)

      wf_point_tags?(opts[:tags]) if opts[:tags]
    end

    def setup_options(user, defaults)
      defaults.merge(user)
    end

    # Send raw data to a Wavefront proxy, automatically opening and
    # closing a socket.
    #
    # @param points [Array[String]] an array of points in native
    #   Wavefront wire format, as described in
    #   https://community.wavefront.com/docs/DOC-1031. No validation
    #   is performed.
    # @param openclose [Boolean] whether or not to automatically
    #   open a socket to the proxy before sending points, and
    #   afterwards, close it.
    #
    def raw(points, openclose = true)
      open if openclose

      begin
        [points].flatten.each{ |p| send_point(p) }
      ensure
        close if openclose
      end
    end

    # Send multiple points to a Wavefront proxy.
    #
    # @param points [Array[Hash]] an array of points. Each point is
    #   defined as a hash with the following keys:
    #     path [String] metric path. (mandatory)
    #     value [Numeric] value of metric. Numeric. Mandatory.
    #     ts [Time, Integer] timestamp for point. Defaults to
    #       current UTC time.
    #     source [String] originating source of metric. Defaults to
    #       the local hostname.
    #     tags [Hash] key: value point tags which will be applied in
    #       addition to any tags defined in the #initialize()
    #       method.
    # @param openclose [Bool] if this is false, you must have
    #   already opened a socket to the proxy. If it is true, a
    #   connection will be opened for you, used, and closed.
    # @raise any unhandled point validation error is passed through
    # @return true if no points are rejected, otherwise false
    #
    def write(points = [], openclose = true)
      open if openclose

      begin
        [points].flatten.each do |p|
          p[:ts] = p[:ts].to_i if p[:ts].is_a?(Time)
          valid_point?(p)
          send_point(hash_to_wf(p))
        end
      ensure
        close if openclose
      end

      s_str = summary[:unsent] == 0 && summary[:rejected] == 0 ? 'OK' :
                                                                 'ERROR'

      resp = { status:   { result: s_str, message: nil, code: nil },
               response: summary }.to_json

      Wavefront::Response.new(resp, nil)
    end

    # A wrapper method around #write() which guarantees all points
    # will be sent as deltas. You can still manually prefix any
    # metric with a Δ and use #write(), but depending on your
    # use-case, this method may be safer. It's easy to forget the Δ.
    #
    # @param points [Array[Hash]] see #write()
    # @param openclose [Bool] see #write()
    #
    def write_delta(points, openclose)
      write(paths_to_deltas(points), openclose)
    end

    # Prefix all paths in a points array (as passed to
    # #write_delta() with a delta symbol
    #
    # @param points [Array[Hash]] see #write()
    # @return [Array[Hash]]
    #
    def paths_to_deltas(points)
      points.map { |p| p.tap { p[:path] = 'Δ' + p[:path] } }
    end

    def valid_point?(p)
      return true if opts[:novalidate]

      begin
        wf_point?(p)
        return true
      rescue Wavefront::Exception::InvalidMetricName,
             Wavefront::Exception::InvalidMetricValue,
             Wavefront::Exception::InvalidTimestamp,
             Wavefront::Exception::InvalidSourceId,
             Wavefront::Exception::InvalidTag => e
        log('Invalid point, skipping.', :info)
        log("Invalid point: #{p}. (#{e})", :debug)
        summary[:rejected] += 1
        return false
      end
    end

    # Convert a validated point to a string conforming to
    # https://community.wavefront.com/docs/DOC-1031.  No validation
    # is done here.
    #
    # @param p [Hash] a hash describing a point. See #write() for
    #   the format.
    #
    # rubocop:disable Metrics/CyclomaticComplexity
    def hash_to_wf(p)
      unless p.key?(:path) && p.key?(:value)
        raise Wavefront::Exception::InvalidPoint
      end

      p[:source] = HOSTNAME unless p.key?(:source)

      m = [p[:path], p[:value]]
      m.<< p[:ts] if p[:ts]
      m.<< 'source=' + p[:source]
      m.<< p[:tags].to_wf_tag if p[:tags]
      m.<< opts[:tags].to_wf_tag if opts[:tags]
      m.join(' ')
    end

    # Send a point which is already in Wavefront wire format.
    #
    # @param point [String] a point description, probably from
    #   #hash_to_wf()
    #
    def send_point(point)
      if opts[:noop]
        log "Would send: #{point}"
        return
      end

      log("Sending: #{point}", :info)

      begin
        sock.puts(point)
      rescue => e
        summary[:unsent] += 1
        log('WARNING: failed to send point.')
        log(e.to_s, :debug)
        return false
      end

      summary[:sent] += 1
      true
    end

    # Open a socket to a Wavefront proxy, putting the descriptor
    # in instance variable @sock.
    #
    def open
      if opts[:noop]
        log('No-op requested. Not opening connection to proxy.')
        return true
      end

      log("Connecting to #{net[:proxy]}:#{net[:port]}.", :info)

      begin
        @sock = TCPSocket.new(net[:proxy], net[:port])
      rescue => e
        log(e, :error)
        raise Wavefront::Exception::InvalidEndpoint
      end
    end

    # Close the socket described by the @sock instance variable.
    #
    def close
      return if opts[:noop]
      log('Closing connection to proxy.', :info)
      sock.close
    end

    private

    # Overload the method which sets an API endpoint. A proxy
    # endpoint has an address and a port, rather than an address and
    # a token.
    #
    def setup_endpoint(creds)
      @net = creds
    end
  end
end
