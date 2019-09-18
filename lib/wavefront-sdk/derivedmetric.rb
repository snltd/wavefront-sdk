# frozen_string_literal: true

require_relative 'core/api'
require_relative 'api_mixins/tag'

module Wavefront
  #
  # View and manage derived metrics
  #
  class DerivedMetric < CoreApi
    include Wavefront::Mixin::Tag

    # GET /api/v2/derivedmetric
    # Get all derived metric definitions for a customer.
    #
    # @param offset [Int] derived metric at which the list begins
    # @param limit [Int] the number of derived metrics to return
    # @return [Wavefront::Response]
    #
    def list(offset = 0, limit = 100)
      api.get('', offset: offset, limit: limit)
    end

    # POST /api/v2/derivedmetric
    # Create a specific derived metric definition.
    # Refer to the Swagger API docs for valid keys.
    #
    # @param body [Hash] description of derived metric
    # @return [Wavefront::Response]
    #
    def create(body)
      raise ArgumentError unless body.is_a?(Hash)

      api.post('', body, 'application/json')
    end

    # DELETE /api/v2/derivedmetric/id
    # Delete a specific derived metric definition.
    # Deleting an active derived metric moves it to 'trash', from
    # where it can be restored with an #undelete operation. Deleting
    # a derived metric in 'trash' removes it for ever.
    #
    # @param id [String] ID of the derived metric
    # @return [Wavefront::Response]
    #
    def delete(id)
      wf_derivedmetric_id?(id)
      api.delete(id)
    end

    # GET /api/v2/derivedmetric/id
    # Get a specific derived metric definition / Get a specific
    # historical version of a specific derived metric definition.
    #
    # @param id [String] ID of the derived metric
    # @param version [Integer] version of derived metric
    # @return [Wavefront::Response]
    #
    def describe(id, version = nil)
      wf_derivedmetric_id?(id)
      wf_version?(version) if version
      fragments = [id]
      fragments += ['history', version] if version
      api.get(fragments.uri_concat)
    end

    # PUT /api/v2/derivedmetric/id
    # Update a specific derived metric definition.
    #
    # @param id [String] a Wavefront alert ID
    # @param body [Hash] key-value hash of the parameters you wish
    #   to change
    # @param modify [true, false] if true, use {#describe()} to get
    #   a hash describing the existing object, and modify that with
    #   the new body. If false, pass the new body straight through.
    # @return [Wavefront::Response]

    def update(id, body, modify = true)
      wf_derivedmetric_id?(id)
      raise ArgumentError unless body.is_a?(Hash)

      return api.put(id, body, 'application/json') unless modify

      api.put(id, hash_for_update(describe(id).response, body),
              'application/json')
    end

    # GET /api/v2/derivedmetric/id/history
    # Get the version history of a derived metric definition.
    #
    # @param id [String] ID of the derived metric
    # @return [Wavefront::Response]
    #
    def history(id)
      wf_derivedmetric_id?(id)
      api.get([id, 'history'].uri_concat)
    end

    # POST /api/v2/derivedmetric/id/undelete
    # Move a derived metric definition from 'trash' back into active
    # service.
    #
    # @param id [String] ID of the derived metric
    # @return [Wavefront::Response]
    #
    def undelete(id)
      wf_derivedmetric_id?(id)
      api.post([id, 'undelete'].uri_concat)
    end

    def valid_id?(id)
      wf_derivedmetric_id?(id)
    end

    private

    def update_keys
      %i[id name query tags additionalInformation
         includeObsoleteMetrics processRateMinutes minutes]
    end
  end
end
