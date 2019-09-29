# frozen_string_literal: true

require_relative 'core/api'

module Wavefront
  #
  # Manage and query Wavefront service accounts
  #
  class ServiceAccount < CoreApi
    def api_base
      '/account/serviceaccount'
    end

    # GET /api/v2/account/serviceaccount
    # Get all service accounts
    #
    # @param offset [Integer] webhook at which the list begins
    # @param limit [Integer] the number of webhooks to return
    #
    def list
      api.get('')
    end

    # POST /api/v2/account/serviceaccount
    # Creates a service account
    # Refer to the Swagger API docs for valid keys.
    #
    # @param body [Hash] description of service account
    # @return [Wavefront::Response]
    #
    def create(body)
      raise ArgumentError unless body.is_a?(Hash)

      api.post('', body, 'application/json')
    end

    # GET /api/v2/account/serviceaccount/{id}
    # Retrieves a service account by identifier
    #
    # @param id [String] ID of the account
    # @return [Wavefront::Response]
    #
    def describe(id)
      wf_serviceaccount_id?(id)
      api.get(id)
    end

    # PUT /api/v2/account/serviceaccount/{id}
    # Updates the service account
    #
    # @param id [String] a Wavefront service account ID
    # @param body [Hash] key-value hash of the parameters you wish
    #   to change
    # @param modify [true, false] if true, use {#describe()} to get
    #   a hash describing the existing object, and modify that with
    #   the new body. If false, pass the new body straight through.
    # @return [Wavefront::Response]
    #
    def update(id, body, modify = true)
      wf_serviceaccount_id?(id)
      raise ArgumentError unless body.is_a?(Hash)

      return api.put(id, body, 'application/json') unless modify

      api.put(id, hash_for_update(describe(id).response, body),
              'application/json')
    end

    # POST /api/v2/account/serviceaccount/{id}/activate
    # Activates the given service account
    #
    # @param id [String] ID of the account
    # @return [Wavefront::Response]
    #
    def activate(id)
      wf_serviceaccount_id?(id)
      api.post([id, 'activate'].uri_concat, nil, 'application/json')
    end

    # POST /api/v2/account/serviceaccount/{id}/deactivate
    # Deactivates the given service account
    #
    # @param id [String] ID of the account
    # @return [Wavefront::Response]
    #
    def deactivate(id)
      wf_serviceaccount_id?(id)
      api.post([id, 'deactivate'].uri_concat, nil, 'application/json')
    end

    def update_keys
      %i[description tokens groups userGroups active identifier]
    end
  end
end
