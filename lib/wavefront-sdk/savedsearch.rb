require_relative './base'

module Wavefront
  #
  # View and manage Cloud Integrations. These are identified by
  # a UUID.
  #
  class SavedSearch < Wavefront::Base

    # GET /api/v2/savedsearch
    # Get all saved searches for a user.
    #
    # @param offset [Int] saved search at which the list begins
    # @param limit [Int] the number of saved searches to return
    # @return [Hash]
    #
    def list(offset = 0, limit = 100)
      api_get('', { offset: offset, limit: limit })
    end

    # POST /api/v2/savedsearch
    # Create a saved search. Refer to the Swagger API docs for
    # valid keys.
    #
    # @param body [Hash] description of saved search
    # @return [Hash]
    #
    def create(body)
      raise ArgumentError unless body.is_a?(Hash)
      api_post('', body, 'application/json')
    end

    # DELETE /api/v2/savedsearch/{id}
    # Delete a specific saved search.
    #
    # @param id [String] ID of the saved search
    # @return [Hash]
    #
    def delete(id)
      wf_savedsearch_id?(id)
      api_delete(id)
    end

    # GET /api/v2/savedsearch/{id}
    # Get a specific saved search.
    #
    # @param id [String] ID of the saved search
    # @return [Hash]
    #
    def describe(id)
      wf_savedsearch_id?(id)
      api_get(id)
    end

    # PUT /api/v2/savedsearch/{id}
    # Update a specific saved search.
    #
    # @param id [String] ID of the saved search
    # @param body [Hash] description of saved search
    #
    def update(id, body)
      wf_savedsearch_id?(id)
      raise ArgumentError unless body.is_a?(Hash)
      api_put(id, body)
    end

    # GET /api/v2/savedsearch/type/{entitytype}
    # Get all saved searches for a specific entity type for a user.
    #
    # @param entitytype [String] type of entity to retrieve
    # @param offset [Int] saved search at which the list begins
    # @param limit [Int] the number of saved searches to return
    # @return [Hash]
    #
    def entity(entitytype, offset = 0, limit = 100)
      wf_savedsearch_entity?(entitytype)
      api_get(['type', entitytype].uri_concat, { offset: offset,
                                                 limit: limit })

    end
  end

  # A standard response
  #
  class Response
    class SavedSearch < Base; end
  end
end
