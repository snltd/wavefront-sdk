require 'json'
require_relative 'summary'
require_relative '../core/response'
require_relative '../validators'

module Wavefront
  module Writer
    #
    # Abstract class extended by the other writers. Methods
    # required whatever mechanism actually sends the points.
    #
    # A point is defined as a hash with the following keys:
    # path   [String] metric path. (mandatory)
    # value  [Numeric] value of metric. Numeric. Mandatory.
    # ts     [Time, Integer] timestamp for point. Defaults to
    #                       current UTC time.
    # source [String] originating source of metric. Defaults to
    #                 the local hostname.
    # tags   [Hash] key:value point tags which will be applied in
    #               addition to any tags defined in the #initialize()
    #               method.
    #
    class Core
      attr_reader :creds, :opts, :logger, :summary, :conn, :calling_class,
        :buffer

      include Wavefront::Validators

      def initialize(calling_class)
        @calling_class = calling_class
        @creds         = calling_class.creds
        @opts          = calling_class.opts
        @logger        = calling_class.logger
        @summary       = Wavefront::Writer::Summary.new

        if opts[:buffer]
          @buffer      = { points:     [],
                           histograms: {},
                           counters:   {} }
        end

        validate_credentials(creds) if respond_to?(:validate_credentials)
        post_initialize(creds, opts) if respond_to?(:post_initialize)
      end

      # Send multiple points to Wavefront.
      #
      # @param points [Array[Hash]] an array of points.
      # @param openclose [Bool] if this is false, you must have
      #   already opened a connection to the proxy. If it is true, a
      #   connection will be opened for you, used, and closed.
      # @param prefix [String] prefix all metrics with this string. No
      #   trailing dot is required.
      # @raise any unhandled point validation error is passed through
      # @return [Wavefront::Response]
      #
      def write(points = [], openclose = true, prefix = nil)
        points = screen_points(points)
        points = prefix_points(points, prefix)

        return buffer_points(buffer[:points]) if buffer
        do_write(points, openclose, prefix)
      end

      def do_write(points, openclose, prefix)
        open if openclose && respond_to?(:open)

        begin
          write_loop(points)
        ensure
          close if openclose && respond_to?(:close)
        end

        respond
      end

      def bcounter(path, value)
        if buffer[:counters].key?(path)
          buffer[:counters][path] += value
        else
          buffer[:counters][path] = value
        end
      end

      def bhist(path, value)
        if buffer[:histograms].key?(path)
          buffer[:histograms][path].<< value
        else
          buffer[:histograms][path] = [value]
        end
      end

      def buffer_points(points)
        @buffer += points
      end

      # Flush the in-memory metric bundle. Same options as #write
      #
      def flush(openclose = true, prefix = nil)
        return unless buffer
        flush_buffer_counters(buffer[:counters])
        flush_buffer_histograms(buffer[:histograms])
        logger.log("flushing buffer of #{buffer[:points].size} point(s)", :debug)
        do_write(buffer[:points], openclose, prefix)
      end

      def flush_buffer_counters(counters)
        logger.log("flushing counter buffer of #{buffer[:counters].size} counter(s)", :debug)
        p(buffer[:counters].map do |p, v|
          { path: p, value: v, ts: Time.now.to_i }
        end)
      end

      def flush_buffer_histograms(histograms)
        logger.log("flushing histogram buffer of #{buffer[:histograms].size} path(s)", :debug)
        buffer[:histograms].map do |p, v|
          puts "#{p} --> #{v}"
        end
      end


      # Send a response object, flushing the buffer (if we have one) if
      # we believe the points were sent successfully.
      #
      def respond
        @buffer[:points] = [] if buffer && summary.ok?

        Wavefront::Response.new(
          { status:   { result: summary.result, message: nil, code: nil },
            response: summary.to_h }.to_json, nil, opts
        )
      end

      # Call the inheriting class's #_send_point method, and handle
      # the summary
      #
      def send_point(point)
        _send_point(point)
        summary.sent += 1
        true
      rescue StandardError => e
        summary.unsent += 1
        logger.log('WARNING: failed to send point.')
        logger.log(e.to_s, :debug)
        false
      end

      # Wrapper around calling_class's #_hash_to_wf to facilitate
      # verbosity/debugging. (The actual work is done in the calling
      # class because it is not always on the same data type.)
      #
      # @param point [Hash] a hash describing a point. See #write() for
      #   the format.
      # @return [String]
      #
      def hash_to_wf(point)
        wf_point = calling_class.hash_to_wf(point)
        logger.log(wf_point, :info)
        wf_point
      end

      # Prefix points with a given string
      # @param points [Array,Hash] one or more points
      # @param prefix [String] prefix to apply to every point
      # @return [Array] of points
      #
      def prefix_points(points, prefix = nil)
        ret = [points].flatten
        return ret unless prefix

        ret.map { |pt| pt.tap { |p| p[:path] = prefix + '.' + p[:path] } }
      end

      # Filter invalid points out of an array of points
      # @param points [Array,Hash] one or more points
      # @return [Array] of points
      #
      def screen_points(points)
        return points if opts[:novalidate]

        [points].flatten.select { |p| valid_point?(p) }
      end

      def valid_point?(point)
        send(calling_class.validation, point)
      rescue Wavefront::Exception::InvalidMetricName,
             Wavefront::Exception::InvalidMetricValue,
             Wavefront::Exception::InvalidTimestamp,
             Wavefront::Exception::InvalidSourceId,
             Wavefront::Exception::InvalidTag => e
        logger.log('Invalid point, skipping.', :info)
        logger.log(e.class, :info)
        logger.log(format('Invalid point: %s (%s)', point, e.to_s), :debug)
        summary.rejected += 1
        false
      end

      private

      def write_loop(points)
        points.each do |p|
          p[:ts] = p[:ts].to_i if p[:ts].is_a?(Time)
          send_point(hash_to_wf(p))
        end
      end
    end
  end
end
