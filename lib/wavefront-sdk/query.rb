require_relative './base'

module Wavefront
  #
  # Query Wavefront metrics.
  #
  class Query < Wavefront::Base
    def api_base
      'chart'
    end

    # Get /api/v2/chart/api
    # Perform a charting query against Wavefront servers that
    # returns the appropriate points in the specified time window
    # and granularity. Any options can be pased through in the
    # options hash. This means the SDK does not have to closely
    # track the API, but also means the burden of data validation is
    # down to the user.
    #
    # @param query [String] Wavefront query to run
    # @param granularity [String] the required granularity for the
    #   reported data
    # @param t_start [Time, Integer] The start of the query window.
    #   May be a Ruby Time object, or epoch milliseconds
    # @param t_end [Time, Integer] The end of the query window.
    #   May be a Ruby Time object, or epoch milliseconds.
    # @param options [Hash] any other options defined in the API
    #
    def query(query, granularity = nil, t_start = nil, t_end = nil,
               options = {})

      raise ArgumentError unless query.is_a?(String)
      wf_granularity?(granularity)
      raise Wavefront::Exception::InvalidTimestamp if t_start.nil?

      options[:q] = query
      options[:g] = granularity
      options[:s] = parse_time(t_start, true)
      options[:e] = parse_time(t_end, true) if t_end

      api_get('api', options.to_qs)
    end
  end
end
