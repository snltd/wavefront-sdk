# frozen_string_literal: true

require_relative 'core/api'

module Wavefront
  #
  # Manage and query Wavefront metrics policies
  #
  class MetricsPolicy < CoreApi
    # GET /api/v2/metricspolicy
    # Get the metrics policy
    # GET /api/v2/metricspolicy/history/{version}
    # Get a specific historical version of a metrics policy
    # @param version [Integer] specify version to describe
    # @return [Wavefront::Response]
    #
    def describe(version = nil)
      if version
        wf_version?(version)
        api.get(['history', version].uri_concat)
      else
        api.get('')
      end
    end

    # GET /api/v2/metricspolicy/history
    # Get the version history of metrics policy
    #
    # @param offset [Integer] version at which the list begins
    # @param limit [Integer] the number of versions to return
    #
    def history(offset = 0, limit = 100)
      api.get('history', offset: offset, limit: limit)
    end

    # POST /api/v2/metricspolicy/revert/{version}
    # Revert to a specific historical version of a metrics policy
    # @param version [Integer] version to revert to
    # @return [Wavefront::Response]
    #
    def revert(version)
      wf_version?(version)
      api.post(['revert', version].uri_concat, nil, 'application/json')
    end

    # PUT /api/v2/metricspolicy
    # Update the metrics policy
    # @param body [Hash] hash describing metrics policy
    # @return [Wavefront::Response]
    #
    def update(body)
      raise ArgumentError unless body.is_a?(Hash)

      api.put('', body, 'application/json')
    end
  end
end
