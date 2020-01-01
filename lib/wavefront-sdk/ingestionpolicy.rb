# frozen_string_literal: true

require_relative 'core/api'

module Wavefront
  #
  # View and manage Wavefront ingestion policies.
  #
  # These use the Usage API path.
  #
  class IngestionPolicy < CoreApi
    def api_base
      '/usage/ingestionpolicy'
    end

    # GET /api/v2/usage/ingestionpolicy
    # Get all ingestion policies for a customer
    #
    # @return [Wavefront::Response]
    #
    # @param offset [Int] ingestion policy at which the list begins
    # @param limit [Int] the number of ingestion policies to return
    # @return [Wavefront::Response]
    #
    def list(offset = 0, limit = 100)
      api.get('', offset: offset, limit: limit)
    end

    # POST /api/v2/usage/ingestionpolicy
    # Create a specific ingestion policy
    #
    # @param body [Hash] description of ingestion policy
    # @return [Wavefront::Response]
    #
    def create(body)
      raise ArgumentError unless body.is_a?(Hash)

      api.post('', body, 'application/json')
    end

    # DELETE /api/v2/usage/ingestionpolicy/{id}
    # Delete a specific ingestion policy
    #
    # @param id [String] ID of the alert
    # @return [Wavefront::Response]
    #
    def delete(id)
      wf_ingestionpolicy_id?(id)
      api.delete(id)
    end

    # GET /api/v2/usage/ingestionpolicy/{id}
    # Get a specific ingestion policy
    #
    # @return [Wavefront::Response]
    # @param id [String] ID of the proxy
    # @return [Wavefront::Response]
    #
    def describe(id)
      wf_ingestionpolicy_id?(id)
      api.get(id)
    end

    # PUT /api/v2/usage/ingestionpolicy/{id}
    # Update a specific ingestion policy
    #
    # @param id [String] a Wavefront alert ID
    # @param body [Hash] key-value hash of the parameters you wish
    #   to change
    # @param modify [true, false] if true, use {#describe()} to get
    #   a hash describing the existing object, and modify that with
    #   the new body. If false, pass the new body straight through.
    # @return [Wavefront::Response]

    def update(id, body, modify = true)
      wf_ingestionpolicy_id?(id)
      raise ArgumentError unless body.is_a?(Hash)

      return api.put(id, body, 'application/json') unless modify

      api.put(id, hash_for_update(describe(id).response, body),
              'application/json')
    end
  end
end
