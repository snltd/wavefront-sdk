# frozen_string_literal: true

require_relative 'core/api'

module Wavefront
  #
  # Manage and query Wavefront external links.
  #
  class ExternalLink < CoreApi
    def api_base
      '/extlink'
    end

    def update_keys
      %i[id name template description metricFilterRegex
         sourceFilterRegex pointTagFilterRegexes]
    end

    # GET /api/v2/extlink
    # Get all external links for a customer
    #
    # @param offset [Int] link at which the list begins
    # @param limit [Int] the number of link to return
    #
    def list(offset = 0, limit = 100)
      api.get('', offset: offset, limit: limit)
    end

    # POST /api/v2/extlink
    # Create a specific external link.
    #
    # @param body [Hash] a description of the external link.
    # @return [Wavefront::Response]
    #
    def create(body)
      raise ArgumentError unless body.is_a?(Hash)

      api.post('', body, 'application/json')
    end

    # DELETE /api/v2/extlink/id
    # Delete a specific external link.
    #
    # @param id [String] ID of the link
    # @return [Wavefront::Response]
    #
    def delete(id)
      wf_link_id?(id)
      api.delete(id)
    end

    # GET /api/v2/extlink/id
    # Get a specific external link.
    #
    # @param id [String] ID of the limnk
    # @return [Wavefront::Response]
    #
    def describe(id)
      wf_link_id?(id)
      api.get(id)
    end

    # PUT /api/v2/extlink/id
    # Update a specific external link.
    #
    # @param id [String] a Wavefront external link ID
    # @param body [Hash] key-value hash of the parameters you wish
    #   to change
    # @param modify [true, false] if true, use {#describe()} to get
    #   a hash describing the existing object, and modify that with
    #   the new body. If false, pass the new body straight through.
    # @return [Wavefront::Response]

    def update(id, body, modify = true)
      wf_link_id?(id)
      raise ArgumentError unless body.is_a?(Hash)

      return api.put(id, body, 'application/json') unless modify

      api.put(id, hash_for_update(describe(id).response, body),
              'application/json')
    end
  end
end
