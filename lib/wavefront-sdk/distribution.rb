require_relative 'write'

module Wavefront
  #
  # Help a user write histogram distributions to a Wavefront proxy
  #
  class Distribution < Write
    #
    # Send multiple distributions to a Wavefront proxy.
    #
    # @param dists [Array[Hash]] an array of distributions. Each
    #   distribution is defined as a hash with the following keys:
    #     interval [Symbol] aggregation interval: :m, :h, :d
    #       (mandatory)
    #     path [String] metric path. (mandatory)
    #     values [Array[Integer, Numeric]] array of arrays of the
    #       form [count, value]
    #     ts [Time, Integer] timestamp. Defaults to current UTC time.
    #     source [String] originating source of metric. Defaults to
    #       the local hostname.
    #     tags [Hash] key: value point tags which will be applied in
    #       addition to any tags defined in the #initialize()
    #       method.
    # @param openclose [Bool] if this is false, you must have
    #   already opened a socket to the proxy. If it is true, a
    #   connection will be opened for you, used, and closed.
    # @param prefix [String] prefix all distribution metric paths
    #   with this string. No trailing dot is required.
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

      Wavefront::Response.new(resp, nil, opts)
    end

    def default_port
      40000
    end

    # Convert a validated point to a string conforming to
    # https://docs.wavefront.com/proxies_histograms.html. No
    # validation is done here.
    #
    # @param point [Hash] a hash describing a distribution. See
    #   #write() for the format.
    #
    # rubocop:disable Metrics/AbcSize
    def hash_to_wf(dist)
      format('!%s %i %s %s source=%s %s %s',
             dist[:interval].to_s.upcase || raise,
             parse_time(dist.fetch(:ts, Time.now)),
             dist_value_string(dist[:values]),
             dist[:path] || raise,
             dist.fetch(:source, HOSTNAME),
             dist[:tags] && dist[:tags].to_wf_tag,
             opts[:tags] && opts[:tags].to_wf_tag).squeeze(' ').strip
    rescue StandardError
      raise Wavefront::Exception::InvalidDistribution
    end
    # rubocop:enable Metrics/AbcSize

    # Turn an array of arrays into a the values part of a distribution
    # @return [String]
    #
    def dist_value_string(values)
      values.map { |x, v| format('#%i %s', x, v) }.join(' ')
    end

    def valid_point?(point)
      return true if opts[:novalidate]
      wf_point?(point)
    rescue Wavefront::Exception::InvalidMetricName,
           Wavefront::Exception::InvalidMetricValue,
           Wavefront::Exception::InvalidTimestamp,
           Wavefront::Exception::InvalidSourceId,
           Wavefront::Exception::InvalidTag => e
      log('Invalid point, skipping.', :info)
      log(format('Invalid point: %s (%s)', point, e.to_s), :debug)
      summary[:rejected] += 1
      false
    end
  end
end
