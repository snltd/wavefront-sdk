require 'socket'
require_relative 'constants'
require_relative 'base'

HOSTNAME = Socket.gethostname.freeze

module Wavefront
  #
  # This class helps you send points to Wavefront. It is extended by
  # the Write and Report classes, which respectively handle point
  # ingestion by a proxy and directly to the API.
  #
  class BaseWrite < Base
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

    # Send multiple points to Wavefront.
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
    # @param prefix [String] prefix all metrics with this string. No
    #   trailing dot is required.
    # @raise any unhandled point validation error is passed through
    # @return true if no points are rejected, otherwise false
    #
    def write(points = [], openclose = true, prefix = nil)
      open if openclose

      begin
        _write_loop(prepped_points(points, prefix))
      ensure
        close if openclose
      end

      s_str = summary_string(summary)

      resp = { status:   { result: s_str, message: nil, code: nil },
               response: summary }.to_json

      Wavefront::Response.new(resp, nil)
    end

    def summary_string(summary)
      summary[:unsent].zero? && summary[:rejected].zero? ? 'OK' : 'ERROR'
    end

    # @return [Array] of points
    #
    def prepped_points(points, prefix = nil)
      ret = [points].flatten

      if prefix
        ret.map! { |pt| pt.tap { |p| p[:path] = prefix + '.' + p[:path] } }
      end

      ret
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
    def write_delta(points, openclose = true)
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

    # rubocop:disable Metrics/MethodLength
    def valid_point?(point)
      return true if opts[:novalidate]

      begin
        wf_point?(point)
        return true
      rescue Wavefront::Exception::InvalidMetricName,
             Wavefront::Exception::InvalidMetricValue,
             Wavefront::Exception::InvalidTimestamp,
             Wavefront::Exception::InvalidSourceId,
             Wavefront::Exception::InvalidTag => e
        log('Invalid point, skipping.', :info)
        log("Invalid point: #{point}. (#{e})", :debug)
        summary[:rejected] += 1
        return false
      end
    end

    # Convert a validated point to a string conforming to
    # https://community.wavefront.com/docs/DOC-1031.  No validation
    # is done here.
    #
    # @param point [Hash] a hash describing a point. See #write() for
    #   the format.
    #
    # rubocop:disable Metrics/AbcSize
    # rubocop:disable Metrics/CyclomaticComplexity
    def hash_to_wf(point)
      unless point.key?(:path) && point.key?(:value)
        raise Wavefront::Exception::InvalidPoint
      end

      point[:source] = HOSTNAME unless point.key?(:source)

      m = [point[:path], point[:value]]
      m.<< point[:ts] if point[:ts]
      m.<< 'source=' + point[:source]
      m.<< point[:tags].to_wf_tag if point[:tags]
      m.<< opts[:tags].to_wf_tag if opts[:tags]
      m.join(' ')
    end

    # Wrapper for #really_send_point(), which really sends points.
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
      really_send_point(point)
    end
  end
end
