require_relative 'core/api'

module Wavefront
  #
  # View and manage derived metrics
  #
  class DerivedMetric < CoreApi
    def update_keys
      # %i[id name url description sections]
    end

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

    # GET /api/v2/derivedmetric/id/tag
    # Get all tags associated with a specific derived metric
    # definition.
    #
    # @param id [String] ID of the derived metric
    # @return [Wavefront::Response]
    #
    def tags(id)
      wf_derivedmetric_id?(id)
      api.get([id, 'tag'].uri_concat)
    end

    # POST /api/v2/derivedmetric/id/tag
    # Set all tags associated with a specific derived metric
    # definition.
    #
    # @param id [String] ID of the derived metric
    # @param tags [Array] list of tags to set.
    # @return [Wavefront::Response]
    #
    def tag_set(id, tags)
      wf_derivedmetric_id?(id)
      tags = Array(tags)
      tags.each { |t| wf_string?(t) }
      api.post([id, 'tag'].uri_concat, tags.to_json, 'application/json')
    end

    # DELETE /api/v2/derivedmetric/id/tag/tagValue
    # Remove a tag from a specific derived metric definition.
    #
    # @param id [String] ID of the derived metric
    # @param tag [String] tag to delete
    # @return [Wavefront::Response]
    #
    def tag_delete(id, tag)
      wf_derivedmetric_id?(id)
      wf_string?(tag)
      api.delete([id, 'tag', tag].uri_concat)
    end

    # PUT /api/v2/derivedmetric/id/tag/tagValue
    # Add a tag to a specific derived metric definition.
    #
    # @param id [String] ID of the derived metric
    # @param tag [String] tag to set.
    # @return [Wavefront::Response]
    #
    def tag_add(id, tag)
      wf_derivedmetric_id?(id)
      wf_string?(tag)
      api.put([id, 'tag', tag].uri_concat)
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
  end
end
