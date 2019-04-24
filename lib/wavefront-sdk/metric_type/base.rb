require_relative '../write'
require_relative '../stdlib/sized_queue'

module Wavefront
  # When a metric is written, it goes on a queue. So we don't need
  # to do any locking on write.
  #
  # When the buffer is flushed, the queue is locked, copied, and
  # processed in a separate thread.
  #
  # If a write fails, we dump the data back in the queue.
  #
  module MetricType
    # An abstract class which is extended by the various metric
    # types we can send.
    #
    # The user accesses the concrete classes via #send and #h_send.
    # These add a point to a queue. #flush! flushes the queue, but
    # this will generally be done by the #flush_loop thread, or
    # possibly by Wavefront::MetricHelper#flush!
    #
    # @param creds [Hash] Wavefront credentials. It is best to use
    #   the SDK's Wavefront::Credentials class, and pass in the #all
    #   object, as that covers API and proxy endpoints.
    # @param opts [Hash] Options to be passed to the chosen Writer
    #   class. See Wavefront::Write#initialize for details
    # @param user_opts [Hash] Options hash governing the way
    #   metrics are handled. Keys are:
    #   queue_size [Integer] how many data points can be put on a
    #     queue. Defaults to 10,000
    #   flush_interval [Integer] by default a thread is started which
    #     flushes points to Wavefront at a preset interval. This
    #     option lets you choose that interval, in seconds. Setting
    #     to zero disables the thread, and you must flush points
    #     yourself. Defaults to 300.
    #   delta_interval [Integer] the size of the time bucket used to
    #     group counter points. Must be a divisor of flush_interval.
    #     If unset, defaults to flush_interval.
    #   nonblock [Boolean] by default the writing thread will not
    #     block if the queue is full. To make it block, set this to
    #     false.
    #   suppress_errors [Boolean] Set this to true to have any
    #     exceptions thrown when writing metrics sent up the stack.
    #     By default they are caught and logged inside the SDK.
    #   dist_port [Integer] proxy port to write distribution
    #     metrics. Defaults to 40000.
    #
    class Base
      attr_reader :queue, :writer, :logger, :metric_opts, :loop,
                  :stop_looping

      def initialize(creds, writer_opts = {}, user_opts = {})
        @metric_opts = setup_metric_opts(user_opts)
        validate_user_options
        @queue        = SizedQueue.new(metric_opts[:queue_size])
        @writer       = setup_writer(creds, writer_opts)
        @logger       = Wavefront::Logger.new(writer_opts)

        return if metric_opts[:flush_interval].zero?
        @loop = Thread.new { flush_loop(metric_opts[:flush_interval]) }
      end

      # Most of the time you just want to send a metric with a value
      # and maybe a couple of tags. Use this. It will set the
      # timestamp to "now" and the source name to the host name of
      # whatever is running your code. The #qq method does all the
      # work, and differs between metric types. This is a
      # wrapper.
      #
      # @param path [String] metric path
      # @param value [Numeric] metric value
      # @param tags [Hash] hash of key-value tags
      #
      def q(path, value, tags = {})
        qq(path:   path,
           ts:     Time.now.utc.to_i,
           value:  value,
           source: HOSTNAME,
           tags:   tags)
      end

      # If you wish to specify things like source and timestamp,
      # which #q does not let you do, you can send a point hash with
      # #qq. Some people may even prefer this to #q, as it's more
      # explicit. You can even send an array of points.
      # @param point [Hash, Array] point, or array of points.
      #
      def qq(point)
        [point].flatten.map { |p| fill_in(p) }.each do |p|
          @queue.push(ready_point(p), metric_opts[:nonblock])
        end
      rescue ThreadError => e
        logger.log("could not send metric: #{e}.", :warn)
        raise unless metric_opts[:suppress_errors]
      end

      # Trigger a flush of the queue. The queue is emptied into a
      # an array which is then passwd on to #to_wf to be turned into
      # Wavefront data. By default the @queue class variable is the
      # queue, but you can pass in your own data, as we do when unit
      # testing
      # @param queue_data [SizedQueue,Array]
      # @return [Boolean] false if any data fails to be sent
      #
      def flush!(queue_data = nil)
        data = queue_data || queue
        logger.log("flushing #{data.length} points [#{log_name}]", :info)
        wf_data = to_wf(data.to_a, Time.now.utc.to_i)
        return true if wf_data.empty?

        send_to_wf(wf_data)
      end

      def validate_user_options; end

      # Close the queue and flush any points, waiting for the thread
      # to complete.
      #
      def close!
        @stop_looping = true
        logger.log("closing #{log_name} queue", :info)
        @loop.join
        flush!
      end

      def ready_point(point)
        point
      end

      # Fill in any essential fields which have been missed out.
      # @param point [Hash] description of point
      # @return [Hash]
      #
      def fill_in(point)
        point.tap do |p|
          p[:source] ||= HOSTNAME
          p[:ts] ||= Time.now.to_f
        end
      end

      # Set up options from defaults
      #
      def setup_metric_opts(user_opts)
        { queue_size:      10_000,
          flush_interval:  300,
          dist_port:       40000,
          nonblock:        true,
          suppress_errors: true }.merge(user_opts).tap do |opts|
            unless opts[:delta_interval]
              opts[:delta_interval] = opts[:flush_interval]
            end
          end
      end

      def setup_writer(creds, writer_opts)
        Wavefront::Write.new(creds, writer_opts)
      end

      # Convert data on the queue into Wavefront format. For some
      # data types this is quite involved.
      # @param data [Array[Hash]]
      # @param _flush_time Unused here, but required by some
      #   inheriting classes.
      # @return [Array[Hash]] of processed data points
      #
      def to_wf(data, _flush_time)
        data
      end

      # Send metrics to Wavefront, using the @writer class.
      # @param data [Array[Hash]] array of points
      # @return [Wavefront::Response]
      #
      def send_to_wf(data)
        _send_to_wf(data).ok? || requeue(data)
      end

      # Broken out fo stubbing
      #
      def _send_to_wf(_data)
        writer.write(data).ok?
      end

      def log_name
        self.class.name
      end

      private

      def requeue(data)
        logger.log("Error sending buffer. Putting #{data.size} " \
                   'points back on queue', :info)
        data.each { |p| qq(p) }
      end

      def flush_loop(sleep_time)
        logger.log("started thread for #{log_name}", :info)

        loop do
          logger.log("#{log_name} sleeping for #{sleep_time}", :info)
          sleep(sleep_time) unless stop_looping == true
          flush!
          break if stop_looping == true
        end
      end
    end
  end
end
