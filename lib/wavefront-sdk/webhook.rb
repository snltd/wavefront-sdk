require_relative './base'

module Wavefront
  #
  # Manage and query Wavefront webhooks
  #
  class Webhook < Base
    def update_keys
      %i(title description template title triggers recipient)
    end

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
    # @return [Wavefront::Response]
    #
    def create(body)
      raise ArgumentError unless body.is_a?(Hash)
      api_post('', body, 'application/json')
    end

    # DELETE /api/v2/webhook/id
    # Delete a specific webhook.
    #
    # @param id [String, Integer] ID of the webhook
    # @return [Wavefront::Response]
    #
    def delete(id)
      wf_webhook_id?(id)
      api_delete(id)
    end

    # GET /api/v2/webhook/id
    # Get a specific webhook.
    #
    # @param id [String, Integer] ID of the webhook
    # @return [Wavefront::Response]
    #
    def describe(id)
      wf_webhook_id?(id)
      api_get(id)
    end

    # PUT /api/v2/webhook/id
    # Update a specific webhook.
    #
    # @param id [String] a Wavefront webhook ID
    # @param body [Hash] key-value hash of the parameters you wish
    #   to change
    # @param modify [true, false] if true, use {#describe()} to get
    #   a hash describing the existing object, and modify that with
    #   the new body. If false, pass the new body straight through.
    # @return [Wavefront::Response]

    def update(id, body, modify = true)
      wf_webhook_id?(id)
      raise ArgumentError unless body.is_a?(Hash)

      return api_put(id, body, 'application/json') unless modify

      api_put(id, hash_for_update(describe(id).response, body),
              'application/json')
    end
  end
end
