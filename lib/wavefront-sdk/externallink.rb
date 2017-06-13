require_relative './base'

module Wavefront
  #
  # Manage and query Wavefront external links.
  #
  class ExternalLink < Base
    def api_base
      '/extlink'
    end

    # GET /api/v2/extlink
    # Get all external links for a customer
    #
    # @param offset [Int] link at which the list begins
    # @param limit [Int] the number of link to return
    #
    def list(offset = 0, limit = 100)
      api_get('', { offset: offset, limit: limit })
    end

    # POST /api/v2/extlink
    # Create a specific external link.
    #
    # @param body [Hash] a description of the external link.
    # @return [Wavefront::Response]
    #
    def create(body)
      raise ArgumentError unless body.is_a?(Hash)
      api_post('', body, 'application/json')
    end

    # DELETE /api/v2/extlink/id
    # Delete a specific external link.
    #
    # @param id [String] ID of the link
    # @return [Wavefront::Response]
    #
    def delete(id)
      wf_link_id?(id)
      api_delete(id)
    end

    # GET /api/v2/extlink/id
    # Get a specific external link.
    #
    # @param id [String] ID of the limnk
    # @return [Wavefront::Response]
    #
    def describe(id)
      wf_link_id?(id)
      api_get(id)
    end

    # PUT /api/v2/extlink/id
    # Update a specific external link.
    #
    # @param id [String] ID of the link
    # @param body [Hash] a key:value hash where the key is the
    #   property to change and the value is its desired value
    # @return [Wavefront::Response]
    #
    def update(id, body)
      wf_link_id?(id)
      raise ArgumentError unless body.is_a?(Hash)
      api_put(id, body)
    end
  end
end
