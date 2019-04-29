require_relative 'write'
require_relative 'distribution'
require_relative 'core/logger'
require_relative 'metric_type/gauge'
require_relative 'metric_type/counter'
require_relative 'metric_type/distribution'

module Wavefront
  #
  # A helper class for quickly and efficiently sending metrics.
  #
  # The user calls methods which access instances of classes for
  # different metric types. Points sent via these methods are put on
  # queues. At flush time the queues are emptied, parsed, and sent
  # to Wavefront. If sending fails, the points are put back on the
  # queue for next time.
  #
  class MetricHelper
    attr_reader :opts, :gauge, :counter, :dist

    # @param creds [Hash] a Wavefront::Credentials object. Which one
    #   you use may depend on the method by which you send your
    #   points. Direct ingestion needs and API token, proxy needs a
    #   proxy address and so-on. Wavefront::Credentials#all will
    #   give you everything, so should always work.
    # @param writer_opts [Hash] Options hash for writing points to
    #   Wavefront. See Wavefront::Write#initialize for parameters.
    #   Additionally,
    #   dist_port: proxy port to write distributions to. If this is
    #              unset, distributions will not be handled.
    #
    # @param metric_opts [Hash] flush interval etc
    #
    def initialize(creds, writer_opts = {}, metric_opts = {})
      @gauge = Wavefront::MetricType::Gauge.new(
        creds, writer_opts, metric_opts
      )
      @counter = Wavefront::MetricType::Counter.new(
        creds, writer_opts, metric_opts
      )
      @dist = Wavefront::MetricType::Distribution.new(
        creds, writer_opts, metric_opts
      )
    end

    # Trigger a flush of all metrics.
    #
    def flush!
      gauge.flush!
      counter.flush!
      dist.flush!
    end

    def close!
      flush_threads = [gauge.flush_thr, counter.flush_thr, dist.flush_thr]

      gauge.close!
      counter.close!
      dist.close!

      flush_threads.each(&:join)
    end
  end
end
