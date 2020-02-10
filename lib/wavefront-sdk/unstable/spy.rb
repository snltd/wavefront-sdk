require_relative '../defs/constants'
require_relative '../core/api'

module Wavefront
  module Unstable
    #
    # This is an unstable class. Please refer to README.md.
    #
    # Everything about this API is different from the public one. To make it
    # appear similar we must change various things we normally take for
    # granted.
    #
    class Spy < CoreApi
      # https://<cluster>.wavefront.com/api/spy/points
      # Gets new metric data points that are added to existing time series.
      # @param filter [Hash] with the following keys:
      #   :prefix [String] only list points whose metric name begins with this
      #     case-sensitive string
      #   :host [String] only list points if source name begins with this
      #     case-sensitive string
      #   :point_tag_key [Array[String]] only list points with one or more of
      #     the given points tags
      #   :sampling [Integer] the amount of points to sample, from 0 (none) to
      #     1 (all)
      # @raise Wavefront::Exception::InvalidSamplingValue
      # @return
      #
      def points(sampling = 0.01, filters = {})
        wf_sampling_value?(sampling)
        api.get_stream('points', points_filter(sampling, filters))
      end

      def points_filter(sampling, filters)
        { metric: filters.fetch(:prefix, nil),
          host: filters.fetch(:host, nil),
          sampling: sampling,
          pointTagKey: filters.fetch(:point_tag_key, nil) }.compact
      end

      # https://<cluster>.wavefront.com/api/spy/spans
      # Gets new spans with existing source names and span tags.
      #
      def spans
      end

      # https://<cluster>.wavefront.com/api/spy/ids
      # Gets newly allocated IDs that correspond to new metric names, source
      # names, point tags, or span tags. A new ID generally indicates that a
      # new time series has been introduced.
      #
      def ids
      end

      def api_path
        '/api/spy'
      end

      # We have to try to make the response we get from the API look
      # like the one we get from the public API. To begin with, it's
      # nothing like it.
      #
      # This method must be public because a #respond_to? looks for
      # it.
      #
      def _response_shim(resp, status)
        { response: parse_response(resp),
            status:  { result:     status == 200 ? 'OK' : 'ERROR',
                       message:    extract_api_message(status, resp),
                       code:       status } }.to_json
      end

      private

      def _parse_response(resp)
        metrics = JSON.parse(resp, symbolize_names: true)[:metrics]

        { items:      metrics,
          offset:     0,
          limit:      metrics.size,
          totalItems: metrics.size,
          moreItems:  false }
      rescue JSON::ParserError
        nil
      end

      def extract_api_message(status, resp)
        resp.match(/^message='(.*)'/)[1]
      rescue NoMethodError
        ''
      end
    end
  end
end
