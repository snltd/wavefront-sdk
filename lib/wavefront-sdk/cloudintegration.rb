# frozen_string_literal: true

require_relative 'core/api'

module Wavefront
  #
  # View and manage Cloud Integrations. These are identified by
  # a UUID.
  #
  class CloudIntegration < CoreApi
    # GET /api/v2/cloudintegration
    # Get all cloud integrations for a customer
    #
    # @param offset [Int] integration at which the list begins
    # @param limit [Int] the number of integration to return
    # @return [Wavefront::Response]
    #
    def list(offset = 0, limit = 100)
      api.get('', offset: offset, limit: limit)
    end

    # POST /api/v2/cloudintegration
    # Create a cloud integration.  Refer to the Swagger API docs for
    # valid keys.
    #
    # @param body [Hash] description of integration
    # @return [Wavefront::Response]
    #
    def create(body)
      raise ArgumentError unless body.is_a?(Hash)

      api.post('', body, 'application/json')
    end

    # DELETE /api/v2/cloudintegration/id
    # Delete a specific cloud integration
    #
    # Deleting an active integration moves it to 'trash', from where
    # it can be restored with an #undelete operation. Deleting an
    # integration in 'trash' removes it for ever.
    #
    # @param id [String] ID of the integration
    # @return [Wavefront::Response]
    #
    def delete(id)
      wf_cloudintegration_id?(id)
      api.delete(id)
    end

    # GET /api/v2/cloudintegration/id
    # Get a specific cloud integration
    #
    # @param id [String] ID of the integration
    # @return [Wavefront::Response]
    #
    def describe(id)
      wf_cloudintegration_id?(id)
      api.get(id)
    end

    # PUT /api/v2/cloudintegration/id
    # Update a specific cloud integration
    #
    # @param id [String] ID of the integration
    # @param body [Wavefront::Response]
    #
    def update(id, body)
      wf_cloudintegration_id?(id)
      raise ArgumentError unless body.is_a?(Hash)

      api.put(id, body)
    end

    # POST /api/v2/cloudintegration/{id}/disable
    # Disable a specific cloud integration
    # @param id [String] ID of the integration
    # @return [Wavefront::Response]
    #
    def disable(id)
      wf_cloudintegration_id?(id)
      api.post([id, 'disable'].uri_concat)
    end

    # POST /api/v2/cloudintegration/{id}/enable
    # Enable a specific cloud integration
    # @param id [String] ID of the integration
    # @return [Wavefront::Response]
    #
    def enable(id)
      wf_cloudintegration_id?(id)
      api.post([id, 'enable'].uri_concat)
    end

    # POST /api/v2/cloudintegration/id/undelete
    # Undelete a specific cloud integration
    #
    # @param id [String] ID of the integration
    # @return [Wavefront::Response]
    #
    def undelete(id)
      wf_cloudintegration_id?(id)
      api.post([id, 'undelete'].uri_concat)
    end
  end
end
