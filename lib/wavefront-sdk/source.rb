require_relative 'core/api'
require_relative 'api_mixins/tag'

module Wavefront
  #
  # View and manage source metadata.
  #
  class Source < CoreApi
    include Wavefront::Mixin::Tag

    def update_keys
      %i[sourceName tags description]
    end

    # GET /api/v2/source
    # Get all sources for a customer
    #
    # @param limit [Integer] the number of sources to return
    # @param cursor [String] source at which the list begins
    # @return [Wavefront::Response]
    #
    def list(limit = nil, cursor = nil)
      qs = {}
      qs[:limit] = limit if limit
      qs[:cursor] = cursor if cursor

      api.get('', qs)
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
      api.post('', body, 'application/json')
    end

    # DELETE /api/v2/source/id
    # Delete metadata (description and tags) for a specific source.
    #
    # @param id [String] ID of the source
    # @return [Wavefront::Response]
    #
    def delete(id)
      wf_source_id?(id)
      api.delete(id)
    end

    # POST /api/v2/source/id/description
    # Set description associated with a specific source

    def description_set(id, description)
      wf_source_id?(id)
      api.post([id, 'description'].uri_concat, description,
               'application/json')
    end

    # DELETE /api/v2/source/id/description
    # Remove description from a specific source

    def description_delete(id)
      wf_source_id?(id)
      api.delete([id, 'description'].uri_concat)
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
      api.get(fragments.uri_concat)
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

      return api.put(id, body, 'application/json') unless modify

      api.put(id, hash_for_update(describe(id).response, body),
              'application/json')
    end

    def valid_id?(id)
      wf_source_id?(id)
    end
  end
end
