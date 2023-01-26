# frozen_string_literal: true

require_relative 'core/api'

module Wavefront
  #
  # View and manage Cloud Integrations. These are identified by
  # a UUID.
  #
  class SavedSearch < CoreApi
    # GET /api/v2/savedsearch
    # Get all saved searches for a user.
    #
    # @param offset [Int] saved search at which the list begins
    # @param limit [Int] the number of saved searches to return
    # @return [Wavefront::Response]
    #
    def list(offset = 0, limit = 100)
      api.get('', offset: offset, limit: limit)
    end

    # POST /api/v2/savedsearch
    # Create a saved search. Refer to the Swagger API docs for
    # valid keys.
    #
    # @param body [Hash] description of saved search
    # @return [Wavefront::Response]
    #
    def create(body)
      raise ArgumentError unless body.is_a?(Hash)

      api.post('', body, 'application/json')
    end

    # DELETE /api/v2/savedsearch/{id}
    # Delete a specific saved search.
    #
    # @param id [String] ID of the saved search
    # @return [Wavefront::Response]
    #
    def delete(id)
      wf_savedsearch_id?(id)
      api.delete(id)
    end

    # GET /api/v2/savedsearch/{id}
    # Get a specific saved search.
    #
    # @param id [String] ID of the saved search
    # @return [Wavefront::Response]
    #
    def describe(id)
      wf_savedsearch_id?(id)
      api.get(id)
    end

    # PUT /api/v2/savedsearch/{id}
    # Update a specific saved search.
    #
    # @param id [String] ID of the saved search
    # @param body [Wavefront::Response]
    #
    def update(id, body)
      wf_savedsearch_id?(id)
      raise ArgumentError unless body.is_a?(Hash)

      api.put(id, body)
    end

    # GET /api/v2/savedsearch/type/{entitytype}
    # Get all saved searches for a specific entity type for a user.
    #
    # @param entitytype [String] type of entity to retrieve
    # @param offset [Int] saved search at which the list begins
    # @param limit [Int] the number of saved searches to return
    # @return [Wavefront::Response]
    #
    def entity(entitytype, offset = 0, limit = 100)
      wf_savedsearch_entity?(entitytype)
      api.get(['type', entitytype].uri_concat, offset: offset,
                                               limit: limit)
    end

    def update_keys
      %i[query entityType]
    end
  end
end
