# frozen_string_literal: true

require_relative 'core/api'

module Wavefront
  #
  # Manage and query Wavefront monitored applications
  #
  class MonitoredApplication < CoreApi
    def update_keys
      %i[hidden application satisfiedLatencyMillis]
    end

    # GET /api/v2/monitoredapplication
    # Get all monitored services
    #
    # @param offset [Integer] application at which the list begins
    # @param limit [Integer] the number of application to return
    #
    def list(offset = 0, limit = 100)
      api.get('', offset: offset, limit: limit)
    end

    # GET /api/v2/monitoredapplication/{application}
    # Get a specific application
    #
    # @param id [String, Integer] ID of the application
    # @return [Wavefront::Response]
    #
    def describe(id)
      wf_monitoredapplication_id?(id)
      api.get(id)
    end

    # PUT /api/v2/monitoredapplication/{application}
    # Update a specific service
    #
    # @param id [String] a Wavefront monitored application ID
    # @param body [Hash] key-value hash of the parameters you wish to change
    # @param modify [true, false] if true, use {#describe()} to get a hash
    #   describing the existing object, and modify that with the new body. If
    #   false, pass the new body straight through.
    # @return [Wavefront::Response]

    def update(id, body, modify = true)
      wf_monitoredapplication_id?(id)
      raise ArgumentError unless body.is_a?(Hash)

      return api.put(id, body, 'application/json') unless modify

      api.put(id, hash_for_update(describe(id).response, body),
              'application/json')
    end
  end
end
