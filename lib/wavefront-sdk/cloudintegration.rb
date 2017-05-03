require_relative './base'

module Wavefront
  #
  # View and manage Cloud Integrations. These are identified by
  # a UUID.
  #
  class CloudIntegration < Wavefront::Base

    # GET /api/v2/cloudintegration
    # Get all cloud integrations for a customer
    #
    # @param offset [Int] integration at which the list begins
    # @param limit [Int] the number of integration to return
    # @return [Hash]
    #
    def list(offset = 0, limit = 100)
      api_get('', { offset: offset, limit: limit })
    end

    # POST /api/v2/cloudintegration
    # Create a cloud integration.  Refer to the Swagger API docs for
    # valid keys.
    #
    # @param body [Hash] description of integration
    # @return [Hash]
    #
    def create(body)
      raise ArgumentError unless body.is_a?(Hash)
      api_post('', body, 'application/json')
    end

    # DELETE /api/v2/cloudintegration/{id}
    # Delete a specific cloud integration
    #
    # Deleting an active integration moves it to 'trash', from where
    # it can be restored with an #undelete operation. Deleting an
    # integration in 'trash' removes it for ever.
    #
    # @param id [String] ID of the integration
    # @return [Hash]
    #
    def delete(id)
      wf_cloudintegration?(id)
      api_delete(id)
    end

    # GET /api/v2/cloudintegration/{id}
    # Get a specific cloud integration
    #
    # @param id [String] ID of the integration
    # @return [Hash]
    #
    def describe(id)
      wf_cloudintegration?(id)
      api_get(id)
    end

    # PUT /api/v2/cloudintegration/{id}
    # Update a specific cloud integration
    #
    # @param id [String] ID of the integration
    # @param body [Hash] description of integration
    #
    def update(id, body)
      wf_cloudintegration?(id)
      raise ArgumentError unless body.is_a?(Hash)
      api_put(id, body)
    end

    # POST /api/v2/cloudintegration/{id}/undelete
    # Undelete a specific cloud integration
    #
    # @param id [String] ID of the integration
    # @return [Hash]
    #
    def undelete(id)
      wf_cloudintegration?(id)
      api_post([id, 'undelete'].uri_concat)
    end
  end
end
