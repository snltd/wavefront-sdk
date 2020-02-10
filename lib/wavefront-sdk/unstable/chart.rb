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
    class Chart < CoreApi
      def metrics_under(path, cursor = nil, limit = 100)
      end

      def make_recursive_call
        raw = api.get('metrics/all',
                      trie: true, q: path, p: cursor, l: limit)

        return raw unless raw.ok?

        metrics = raw.response.items

        metrics.each do |m|
          if m.end_with?('.')
            metrics += metrics_under(m).response.items
            metrics.delete(m)
          end
        end

        # raw.more_items? doesn't work: we don't get that from this
        # API

        if metrics.size == limit
          metrics += metrics_under(path, metrics.last, limit).response.items
        end

        raw.items = metrics.sort
        raw
      end


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
