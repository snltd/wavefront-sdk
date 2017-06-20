require_relative './base'

module Wavefront
  #
  # View and manage source metadata.
  #
  class Source < Base
    def update_keys
      %i(sourceName tags description)
    end

    # GET /api/v2/source
    # Get all sources for a customer
    #
    # @param offset [Int] source at which the list begins
    # @param limit [Int] the number of sources to return
    # @return [Wavefront::Response]
    #
    def list(offset = 0, limit = 100)
      api_get('', { offset: offset, limit: limit })
    end

    # POST /api/v2/source
    # Create metadata (description or tags) for a specific source.
    #
    # Refer to the Swagger API docs for valid keys.
    #
    # @param body [Hash] description of source
    # @return [Wavefront::Response]
    #
    def create(body)
      raise ArgumentError unless body.is_a?(Hash)
      api_post('', body, 'application/json')
    end

    # DELETE /api/v2/source/id
    # Delete metadata (description and tags) for a specific source.
    #
    # @param id [String] ID of the source
    # @return [Wavefront::Response]
    #
    def delete(id)
      wf_source_id?(id)
      api_delete(id)
    end

    # GET /api/v2/source/id
    # Get a specific source for a customer.
    #
    # @param id [String] ID of the source
    # @return [Wavefront::Response]
    #
    def describe(id, version = nil)
      wf_source_id?(id)
      wf_version?(version) if version
      fragments = [id]
      fragments += ['history', version] if version
      api_get(fragments.uri_concat)
    end

    # PUT /api/v2/source/id
    # Update metadata (description or tags) for a specific source.
    #
    # @param id [String] a Wavefront alert ID
    # @param body [Hash] key-value hash of the parameters you wish
    #   to change
    # @param modify [true, false] if true, use {#describe()} to get
    #   a hash describing the existing object, and modify that with
    #   the new body. If false, pass the new body straight through.
    # @return [Wavefront::Response]

    def update(id, body, modify = true)
      wf_source_id?(id)
      raise ArgumentError unless body.is_a?(Hash)

      return api_put(id, body, 'application/json') unless modify

      api_put(id, hash_for_update(describe(id).response, body),
              'application/json')
    end

    # GET /api/v2/source/id/tag
    # Get all tags associated with a specific source.
    #
    # @param id [String] ID of the source
    # @return [Wavefront::Response]
    #
    def tags(id)
      wf_source_id?(id)
      api_get([id, 'tag'].uri_concat)
    end

    # POST /api/v2/source/id/tag
    # Set all tags associated with a specific source.
    #
    # @param id [String] ID of the source
    # @param tags [Array] list of tags to set.
    # @return [Wavefront::Response]
    #
    def tag_set(id, tags)
      wf_source_id?(id)
      tags = Array(tags)
      tags.each { |t| wf_string?(t) }
      api_post([id, 'tag'].uri_concat, tags.to_json, 'application/json')
    end

    # DELETE /api/v2/source/id/tag/tagValue
    # Remove a tag from a specific source.
    #
    # @param id [String] ID of the source
    # @param tag [String] tag to delete
    # @return [Wavefront::Response]
    #
    def tag_delete(id, tag)
      wf_source_id?(id)
      wf_string?(tag)
      api_delete([id, 'tag', tag].uri_concat)
    end

    # PUT /api/v2/source/id/tag/tagValue
    # Add a tag to a specific source
    #
    # @param id [String] ID of the source
    # @param tag [String] tag to set.
    # @return [Wavefront::Response]
    #
    def tag_add(id, tag)
      wf_source_id?(id)
      wf_string?(tag)
      api_put([id, 'tag', tag].uri_concat)
    end
  end
end
