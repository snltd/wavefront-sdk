require 'json'
require_relative 'summary'
require_relative '../core/response'

module Wavefront
  module Writer
    #
    # Abstract class inherited by the other writers. Methods you'll
    # need whatever mechanism actually sends the points.
    #
    class Core
      attr_reader :creds, :opts, :logger, :summary, :conn, :calling_class

      include Wavefront::Validators

      def initialize(calling_class)
        @calling_class = calling_class
        @creds   = calling_class.creds
        @opts    = calling_class.opts
        @logger  = calling_class.logger
        @summary = Wavefront::Writer::Summary.new

        validate_credentials(creds)
        post_initialize(creds, opts) if respond_to?(:post_initialize)
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
      #   already opened a connection to the proxy. If it is true, a
      #   connection will be opened for you, used, and closed.
      # @param prefix [String] prefix all metrics with this string. No
      #   trailing dot is required.
      # @raise any unhandled point validation error is passed through
      # @return true if no points are rejected, otherwise false
      #
      # rubocop:disable Metrics/AbcSize
      def write(points = [], openclose = true, prefix = nil)
        open if openclose && respond_to?(:open)

        points = screen_points(points) unless opts[:novalidate]

        begin
          write_loop(prepped_points(points, prefix))
        ensure
          close if openclose && respond_to?(:close)
        end

        resp = { status:   { result:  summary.result,
                             message: nil,
                             code:    nil },
                 response: summary.to_h }.to_json

        Wavefront::Response.new(resp, nil, opts)
      end
      # rubocop:enable Metrics/AbcSize

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
        p = calling_class.hash_to_wf(point)
        logger.log(p, :info)
        p
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

      def screen_points(points)
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
