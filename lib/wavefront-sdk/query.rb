# frozen_string_literal: true

require_relative 'core/api'

module Wavefront
  #
  # Query Wavefront metrics.
  #
  class Query < CoreApi
    def api_base
      'chart'
    end

    # GET /api/v2/chart/api
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
    # @raise [ArgumentError] if query is not a string
    # @return [Wavefront::Response]
    #
    # rubocop:disable Metrics/ParameterLists
    def query(query, granularity = nil, t_start = nil, t_end = nil,
              options = {})

      raise ArgumentError unless query.is_a?(String)

      wf_granularity?(granularity)
      raise Wavefront::Exception::InvalidTimestamp if t_start.nil?

      options[:q] = query
      options[:g] = granularity
      options[:s] = parse_time(t_start, true)
      options[:e] = parse_time(t_end, true) if t_end

      api.get('api', options)
    end
    # rubocop:enable Metrics/ParameterLists

    # GET /api/v2/chart/raw
    # Perform a raw data query against Wavefront servers that
    # returns second granularity points grouped by tags
    #
    # @param metric [String]  metric to query ingested points for
    #   (cannot contain wildcards)
    # @param source [String] source to query ingested points for
    #   (cannot contain wildcards).
    # @param t_start [Time, Integer] start time of window: defaults
    #   to one hour before t_end
    # @param t_end [Time, Integer] end time of window: defaults
    #   to now
    #
    def raw(metric, source = nil, t_start = nil, t_end = nil)
      raise ArgumentError unless metric.is_a?(String)

      options = { metric: metric }

      if source
        wf_source_id?(source)
        options[:source] = source
      end

      options[:startTime] = parse_time(t_start, true) if t_start
      options[:endTime] = parse_time(t_end, true) if t_end

      api.get('raw', options)
    end

    # Fake a response which looks like we get from all the other
    # paths. The default response is a single array.
    #
    # I don't know if something has changed in the API, but sending
    # a complete nonsense query like 'st("some.series")' returns an
    # error message, but with a 200 code. So we fudge a 400 if we
    # see a message.
    #
    def response_shim(body, status)
      resp, err_msg = parsed_response(body)

      status = 400 if status == 200 && !err_msg.empty?

      { response: resp,
        status: { result: status == 200 ? 'OK' : 'ERROR',
                  message: err_msg,
                  code: status } }.to_json
    end

    # A bad query doesn't send back a JSON object. It sends back a
    # string with an embedded message.
    # @return [Array] [parsed body of response, error_message]. One
    #   or the other
    #
    def parsed_response(body)
      [JSON.parse(body), '']
    rescue JSON::ParserError
      ['', extract_error_message(body)]
    end

    # There ought to be a message= block in the response, but
    # sometimes there isn't. So far it seems that in this second
    # case, the message is on its own line.
    #
    def extract_error_message(body)
      body.match(/message='([^']+)'/).captures.first
    rescue StandardError
      body.lines.last.strip
    end
  end
end
