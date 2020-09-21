# frozen_string_literal: true

require_relative 'core/api'

module Wavefront
  #
  # View and manage API tokens for one's own user, and for service accounts.
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

    # GET /api/v2/apitoken/serviceaccount/{id}
    # Get all api tokens for the given service account
    #
    # @param id [String] service account ID
    # @return [Wavefront::Response]
    #
    def sa_list(id)
      wf_serviceaccount_id?(id)
      api.get(['serviceaccount', id].uri_concat)
    end

    # POST /api/v2/apitoken/serviceaccount/{id}
    # Create a new api token for the service account
    #
    # @param id [String] service account ID
    # @param name [String] optional name for token
    # @return [Wavefront::Response]
    #
    def sa_create(id, name = nil)
      wf_serviceaccount_id?(id)
      body = {}.tap { |b| b[:tokenName] = name if name }
      api.post(['serviceaccount', id].uri_concat, body, 'application/json')
    end

    # DELETE /api/v2/apitoken/serviceaccount/{id}/{token}
    # Delete the specified api token of the given service account
    #
    # @param id [String] service account ID
    # @param token_id [String] ID of the api token
    # @return [Wavefront::Response]
    #
    def sa_delete(id, token_id)
      wf_serviceaccount_id?(id)
      wf_apitoken_id?(token_id)
      api.delete(['serviceaccount', id, token_id].uri_concat)
    end

    # PUT /api/v2/apitoken/serviceaccount/{id}/{token}
    # Update the name of the specified api token for the given service
    # account
    #
    # @param id [String] service account ID
    # @param token_id [String] ID of the api token
    # @return [Wavefront::Response]
    #
    def sa_rename(id, token_id, name)
      wf_serviceaccount_id?(id)
      wf_apitoken_id?(token_id)
      api.put(['serviceaccount', id, token_id].uri_concat,
              { tokenID: token_id, tokenName: name }, 'application/json')
    end
  end
end
