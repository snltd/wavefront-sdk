require_relative 'base'

module Wavefront
  module MetricType
    #
    # Counters are pulled off the queue and turned into delta
    # metrics.
    #
    class Counter < Base
      # Come flush time we have to group similar points. We define
      # "similar" as "same path and tags". So any sent points go on
      # the queue as a hash where they key is an array of the path,
      # timestamp, and tags. (Source is a tag, remember.) We can
      # easily group these together later. We'll call these
      # "intermediate format" points.
      #
      def ready_point(point)
        { key:   [point[:path], point[:source], point[:tags]],
          ts:    point[:ts],
          value: point[:value] }
      end

      # We have a whole heap of intermediate points in the queue,
      # which need to be converted to a (probably) much smaller
      # number of delta metrics. The user can set a delta_interval,
      # which must be a divisor of the flush interval.
      # @param data [Array[Hash]] array of intermediate points
      # @flush_time [Integer] time at which flush began
      # @return [Array[Hash]] array of Wavefront SDK format points
      #
      def to_wf(data, flush_time)
        b = bucketed_data(data, flush_time, metric_opts[:delta_interval])
        b.map { |p| bucket_to_point(*p) }.flatten
      end

      # Divides up data according to its timestamp. A bucket is
      # reduced to a point whose timestamp is the last second of the
      # bucket. We are given the time that the flush started, so
      # we'll count back from there to the earliest point we have.
      # No point going beyond that, and we don't know how old it
      # might be, since there could be requeued data. This means any
      # points with a future timestamp will be lost. Tough luck, you
      # shouldn't be sending points with a future timestamp.
      # @param data [Array[Hash]] intermediate points
      # @param flush_time [Integer] epoch time at which flush began
      # @param interval [Integer] width of bucket, in seconds
      # @return [Array[Array]] [points, timestamp_for_end_of_bucket]
      #
      def bucketed_data(data, flush_time, interval = nil)
        return [] if data.empty?

        interval ||= metric_opts[:delta_interval]

        t_start = earliest_point(data)

        flush_time.step(t_start, -interval).with_object([]) do |t, a|
          points = points_in_range(data, t, interval)
          a.<< [points, t] unless points.empty?
        end
      end

      # @return [Integer] timestamp of earliest point
      #
      def earliest_point(data)
        data.map { |p| p[:ts] }.min
      end

      # Takes a range of points from an array of points.
      # @param data [Array[Hash]] array of points
      # @param t_end [Integer] epoch timestamp of end of bucket
      # @param interval [Integer] size of bucket, in seconds
      # @return [Array[Hash]]
      #
      def points_in_range(data, t_end, interval)
        data.select { |p| p[:ts] > t_end - interval && p[:ts] <= t_end }
      end

      # Takes an arbitrary number of points and boils them down to
      # an array of delta points. Points with common identification
      # data are combined.
      # @param data [Array[Hash]] array of points
      # @param t_end [Integer] timestamp for the end of the bucket,
      #   and therefore for the resultant point.  This is not
      #   necessarily (in fact, probably is not), the timestamp of
      #   the last point.
      # @return [Array[Hash]] array of delta points
      #
      def bucket_to_point(data, t_end)
        return [] if data.empty?

        unique_keys(data).each_with_object([]) do |k, a|
          points = data.select { |p| p[:key] == k }
          a.<< metric_bucket_to_point(points, t_end)
        end
      end

      # @param data [Array[Hash]]
      # @return [Array] all unique values of :key in @data
      #
      def unique_keys(data)
        data.map { |p| p[:key] }.uniq
      end

      # Take an array of intermediate format points and turn them
      # into one real point
      # @param kdata [Array[Hash]] intermediate points
      # @param t_end [Integer] epoch timestamp
      # @return [Array[Hash]] real point read to be sent to Wavefront
      #
      def metric_bucket_to_point(kdata, t_end)
        return [] if kdata.empty?

        eg = kdata.first

        { path:   eg[:key][0],
          source: eg[:key][1],
          ts:     t_end,
          value:  kdata.map { |p| p[:value] }.inject(:+),
          tags:   eg[:key][2] }
      end

      def validate(point)
        wf_point?(point)
        return true unless point[:value].negative?

        raise Wavefront::Exception::InvalidCounterValue
      end

      def _send_to_wf(data)
        writer.write_delta(data)
      end

      def validate_user_options
        unless (metric_opts[:flush_interval] %
            metric_opts[:delta_interval]).zero?
          raise Wavefront::Exception::InvalidInterval
        end
      end
    end
  end
end
