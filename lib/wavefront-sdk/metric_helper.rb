# frozen_string_literal: true

require_relative 'write'

module Wavefront
  #
  # A helper class for quickly and efficiently sending metrics.
  # This class creates an in-memory buffer to which you can write
  # information using a number of methods. When the buffer is
  # flushed, the points are send to Wavefront using any Writer
  # class. You can currently write gauges, counters, and
  # distributions. This list may grow in the future.
  #
  class MetricHelper
    attr_reader :opts, :buf, :writer, :dist_writer

    # See Wavefront::Write#initialize for parameters. Additionally,
    #   dist_port: proxy port to write distributions to. If this is
    #              unset, distributions will not be handled.
    #
    def initialize(creds, opts = {})
      @opts        = opts
      @buf         = { gauges: empty_gauges,
                       counters: empty_counters }
      @writer      = setup_writer(creds, opts)
      @dist_writer = setup_dist_writer(creds, opts) if opts[:dist_port]
    end

    # Writes a simple path/metric point, with optional tags,
    # to the buffer. The timestamp is automatically set to the
    # current epoch second. For more control, use
    # Wavefront::Write#write
    # @param path [String] metric path
    # @param value [Numeric] metric value
    # @param tags [Hash] hash of point tags
    #
    def gauge(path, value, tags = nil)
      gauge = { path: path, ts: Time.now.to_i, value: value }
      gauge[:tags] = tags if tags
      @buf[:gauges] << gauge
    end

    # These counters are internal, and specific to the SDK. When
    # the buffer is flushed, a single value is sent to Wavefront
    # for each counter. The value sent is a Wavefront delta metric.
    #
    # @param path [String] metric path
    # @param value [Numeric] value to add to counter
    # @param tags [Hash] point tags
    #
    def counter(path, value = 1, tags = nil)
      key = [path, tags]
      @buf[:counters][key] += value
    end

    # These distributions are stored in memory, and sent to
    # Wavefront as native distibutions when the buffer is flushed.
    # @param path [String] metric path
    # @param value [Array, Numeric] value(s) to add to distribution
    # @param interval [Symbol, String] distribution interval, :m,
    #   :h, or :d
    # @param tags [Hash] point tags
    #
    def dist(path, interval, value, tags = nil)
      key = [path, interval, tags]
      @buf[:dists][key] += [value].flatten
    end

    # Flush all stored metrics. Though you can flush by individual
    # type, this is the preferred method
    #
    def flush
      flush_gauges(buf[:gauges])
      flush_counters(buf[:counters])
      flush_dists(buf[:dists]) if opts.key?(:dist_port)
    end

    # When we are asked to flush the buffers, duplicate the current
    # one, hand it off to the writer class, and clear. If writer
    # tells us there was an error, dump the old buffer into the
    # the new one for the next flush.
    #
    def flush_gauges(gauges)
      return if gauges.empty?

      to_flush = gauges.dup
      @buf[:gauges] = empty_gauges

      writer.write(gauges_to_wf(gauges)).tap do |resp|
        @buf[:gauges] += to_flush unless resp.ok?
      end
    end

    def flush_counters(counters)
      return if counters.empty?

      to_flush = counters.dup
      @buf[:counters] = empty_counters

      writer.write_delta(counters_to_wf(counters)).tap do |resp|
        replay_counters(to_flush) unless resp.ok?
      end
    end

    def flush_dists(dists)
      return if dists.empty?

      to_flush = dists.dup
      @buf[:dists] = empty_dists

      dist_writer.write(dists_to_wf(dists)).tap do |resp|
        replay_dists(to_flush) unless resp.ok?
      end
    end

    # Play a failed flush full of counters back into the system
    #
    def replay_counters(buffer)
      buffer.each { |k, v| counter(k[0], v, k[1]) }
    end

    def replay_dists(buffer)
      buffer.each { |k, v| dist(k[0], k[1], v, k[2]) }
    end

    # These are already Wavefront-format points
    #
    def gauges_to_wf(gauges)
      gauges
    end

    def counters_to_wf(counters)
      counters.map do |k, v|
        path, tags = k
        metric = { path: path, value: v, ts: Time.now.utc.to_i }
        metric[:tags] = tags unless tags.nil?
        metric
      end
    end

    def dists_to_wf(dists)
      dists.map do |k, v|
        path, interval, tags = k
        dist = { path: path,
                 value: dist_writer.mk_distribution(v),
                 ts: Time.now.utc.to_i,
                 interval: interval }
        dist[:tags] = tags unless tags.nil?
        dist
      end
    end

    # @return [Hash] options hash, with :port replaced by :dist_port
    #
    def dist_creds(creds, opts)
      creds.dup.tap { |o| o[:port] = opts[:dist_port] }
    end

    private

    def empty_gauges
      []
    end

    def empty_counters
      Hash.new(0)
    end

    def empty_dists
      Hash.new([])
    end

    def setup_writer(creds, opts)
      Wavefront::Write.new(creds, opts)
    end

    def setup_dist_writer(creds, opts)
      require_relative 'distribution'
      @buf[:dists] = empty_dists
      Wavefront::Distribution.new(dist_creds(creds, opts), opts)
    end
  end
end
