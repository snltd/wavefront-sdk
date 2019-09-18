# frozen_string_literal: true

require_relative 'core/api'

module Wavefront
  #
  # View and manage API tokens
  #
  class ApiToken < CoreApi
    # GET /api/v2/apitoken
    # Get all api tokens for a user
    #
    # @return [Wavefront::Response]
    #
    def list
      api.get('')
    end

    # POST /api/v2/apitoken
    # Create a new api token
    #
    # @return [Wavefront::Response]
    #
    def create
      api.post('', nil, 'application/json')
    end

    # DELETE /api/v2/apitoken/id
    # Delete the specified api token
    #
    # @param id [String] ID of the api token
    # @return [Wavefront::Response]
    #
    def delete(id)
      wf_apitoken_id?(id)
      api.delete(id)
    end

    # PUT /api/v2/apitoken/id
    # Update the name of the specified api token
    #
    # @param id [String] ID of the API token
    # @param name [String] name of the API token
    # @return [Wavefront::Response]

    def rename(id, name)
      wf_apitoken_id?(id)
      api.put(id, { tokenID: id, tokenName: name }, 'application/json')
    end
  end
end
