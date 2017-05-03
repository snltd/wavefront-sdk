require_relative './base'

module Wavefront
  #
  # Manage and query Wavefront webhooks
  #
  class Webhook < Wavefront::Base

    # GET /api/v2/webhook
    # Get all webhooks for a customer.
    #
    # @param offset [Integer] webhook at which the list begins
    # @param limit [Integer] the number of webhooks to return
    #
    def list(offset = 0, limit = 100)
      api_get('', { offset: offset, limit: limit })
    end

    # POST /api/v2/webhook
    # Create a specific webhook.
    #
    # @param body [Hash] a hash of parameters describing the webhook.
    #   Please refer to the Wavefront Swagger docs for key:value
    #   information
    # @return [Hash]
    #
    def create(body)
      raise ArgumentError unless body.is_a?(Hash)
      api_post('', body, 'application/json')
    end

    # DELETE /api/v2/webhook/{id}
    # Delete a specific webhook.
    #
    # @param id [String, Integer] ID of the webhook
    # @return [Hash]
    #
    def delete(id)
      wf_webhook?(id)
      api_delete(id)
    end

    # GET /api/v2/webhook/{id}
    # Get a specific webhook.
    #
    # @param id [String, Integer] ID of the webhook
    # @return [Hash]
    #
    def describe(id)
      wf_webhook?(id)
      api_get(id)
    end

    # PUT /api/v2/webhook/{id}
    # Update a specific webhook.
    #
    # @param body [Hash] a hash of parameters describing the webhook.
    # @return [Hash]
    # @raise any validation errors from body
    #
    def update(id, body)
      wf_webhook?(id)
      raise ArgumentError unless body.is_a?(Hash)
      api_put(id, body)
    end
  end
end
