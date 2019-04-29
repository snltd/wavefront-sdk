require_relative 'base'
require_relative '../distribution'

module Wavefront
  module MetricType
    # Dists
    class Distribution < Base
      # @param path [String] metric path
      # @param value Array[[Numeric]] distribution. This can be
      #   described as a simple array of numbers, as an array of [x,
      #   y] arrays, or even a mix of the two.
      # @param tags [Hash] hash of key-value tags
      #
      def q(path, interval, value, tags = {})
        qq(path:     path,
           interval: interval,
           ts:       Time.now.utc.to_i,
           value:    value,
           source:   HOSTNAME,
           tags:     tags)
      end

      # Note that we flatten any distribution. This lets our users
      # send flat distributions, which are easier to build, but
      # deals with the nested distributions we put back on the
      # queue.
      # @param point [Hash]
      # @return [Hash]
      #
      def ready_point(point)
        { key:   [point[:path], point[:source], point[:interval],
                  point[:tags]],
          ts:    point[:ts],
          value: unpack_distribution(point[:value]) }
      end

      # Take a distribution described as [1, 1, 2, 3], or [[2, 1],
      # [1, 2], [1, 3]] and turn it into [1, 1, 2, 3]
      #
      # @param dist [Array, Array[Array]]
      # @return [Array]
      #
      def unpack_distribution(dist)
        dist.each_with_object([]) do |n, a|
          if n.is_a?(Numeric)
            a.<< n
          elsif n.is_a?(Array)
            n[0].times { a.<< n[1] }
          end
        end
      end

      def to_wf(data, _flush_time = nil)
        data.map do |p|
          path, source, interval, tags = p[:key]
          { path:     path,
            value:    writer.mk_distribution(p[:value]),
            ts:       p[:ts],
            source:   source,
            interval: interval,
            tags:     tags }
        end
      end

      def validate(point)
        wf_distribution?(point, true)
      end

      # @return [Hash] options hash, with :port replaced by :dist_port
      #
      def dist_creds(creds)
        creds.dup.tap { |o| o[:port] = metric_opts[:dist_port] }
      end

      def setup_writer(creds, writer_opts)
        Wavefront::Distribution.new(dist_creds(creds), writer_opts)
      end
    end
  end
end
