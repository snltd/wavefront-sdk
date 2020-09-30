# frozen_string_literal: true

require_relative '../defs/constants'
require_relative '../core/api'

module Wavefront
  module Unstable
    #
    # This is an unstable class. Please refer to README.md.
    #
    class Chart < CoreApi
      def all_metrics
        metrics_under('')
      end

      # Gets a list of metrics under the given path. This must be done via
      # recursive calls to the API, so calls can take a while. If you ask for
      # all your metrics, expect to be waiting some time.
      #
      # @return [Wavefront::Response]
      #
      # rubocop:disable Metrics/MethodLength
      # rubocop:disable Metrics/AbcSize
      def metrics_under(path, cursor = nil, limit = 100)
        resp = api.get('metrics/all',
                       { trie: true, q: path, p: cursor, l: limit }.compact)

        return resp unless resp.ok?

        metrics = resp.response.items

        metrics.each do |m|
          if m.end_with?('.')
            metrics += metrics_under(m).response.items
            metrics.delete(m)
          end
        end

        # resp.more_items? doesn't work: we don't get that from this API

        if metrics.size == limit
          metrics += metrics_under(path, metrics.last, limit).response.items
        end

        resp.response.items = metrics.sort
        resp
      end
      # rubocop:enable Metrics/MethodLength
      # rubocop:enable Metrics/AbcSize

      def api_path
        '/chart'
      end

      # We have to try to make the response we get from the API look
      # like the one we get from the public API. To begin with, it's
      # nothing like it.
      #
      # This method must be public because a #respond_to? looks for
      # it.
      #
      def response_shim(resp, status)
        { response: parse_response(resp),
          status: { result: status == 200 ? 'OK' : 'ERROR',
                    message: extract_api_message(status, resp),
                    code: status } }.to_json
      end

      private

      def parse_response(resp)
        metrics = JSON.parse(resp, symbolize_names: true)[:metrics]

        { items: metrics,
          offset: 0,
          limit: metrics.size,
          totalItems: metrics.size,
          moreItems: false }
      rescue JSON::ParserError
        nil
      end

      def extract_api_message(_status, resp)
        resp.match(/^message='(.*)'/)[1]
      rescue NoMethodError
        ''
      end
    end
  end
end
