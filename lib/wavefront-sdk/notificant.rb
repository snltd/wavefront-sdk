require_relative 'base'

module Wavefront
  #
  # Manage and query Wavefront notification targets.
  #
  class Notificant < Base
    # GET /api/v2/notificant
    # Get all notification targets for a customer
    #
    # @param offset [Int] notificant at which the list begins
    # @param limit [Int] the number of notification targets to return
    #
    def list(offset = 0, limit = 100)
      api_get('', offset: offset, limit: limit)
    end

    # POST /api/v2/notificant
    # Create a notification target.
    #
    # @param body [Hash] description of notification target
    # @return [Wavefront::Response]
    #
    def create(body)
      raise ArgumentError unless body.is_a?(Hash)
      api_post('', body, 'application/json')
    end

    # DELETE /api/v2/notificant/id
    # Delete a specific notificant
    #
    # @param id [String] ID of the notification target
    # @return [Wavefront::Response]
    #
    def delete(id)
      wf_notificant_id?(id)
      api_delete(id)
    end

    # GET /api/v2/notificant/id
    # Get a specific notification target
    #
    # @param id [String] ID of the notification target
    # @return [Wavefront::Response]
    #
    def describe(id)
      wf_notificant_id?(id)
      api_get(id)
    end

    # PUT /api/v2/notificant/id
    # Update a specific notification target
    #
    # @param id [String] a Wavefront notification target ID
    # @param body [Hash] key-value hash of the parameters you wish
    #   to change
    # @param modify [true, false] if true, use {#describe()} to get
    #   a hash describing the existing object, and modify that with
    #   the new body. If false, pass the new body straight through.
    # @return [Wavefront::Response]

    def update(id, body, modify = true)
      wf_notificant_id?(id)
      raise ArgumentError unless body.is_a?(Hash)

      return api_put(id, body, 'application/json') unless modify

      api_put(id, hash_for_update(describe(id).response, body),
              'application/json')
    end

    # POST /api/v2/notificant/test/id
    # Create a notification target.
    #
    # @param body [Hash] description of notification target
    # @return [Wavefront::Response]
    #
    def test(id)
      wf_notificant_id?(id)
      api_post(['test', id].uri_concat, nil)
    end
  end
end
