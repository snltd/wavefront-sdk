# frozen_string_literal: true

require_relative 'core/api'
require_relative 'api_mixins/acl'
require_relative 'api_mixins/tag'

module Wavefront
  #
  # View and manage dashboards.
  #
  class Dashboard < CoreApi
    include Wavefront::Mixin::Acl
    include Wavefront::Mixin::Tag

    def update_keys
      %i[id name url description sections]
    end

    # GET /api/v2/dashboard
    # Get all dashboards for a customer.
    #
    # @param offset [Int] dashboard at which the list begins
    # @param limit [Int] the number of dashboards to return
    # @return [Wavefront::Response]
    #
    def list(offset = 0, limit = 100)
      api.get('', offset: offset, limit: limit)
    end

    # POST /api/v2/dashboard
    # Create a specific dashboard.
    # Refer to the Swagger API docs for valid keys.
    #
    # @param body [Hash] description of dashboard
    # @return [Wavefront::Response]
    #
    def create(body)
      raise ArgumentError unless body.is_a?(Hash)

      api.post('', body, 'application/json')
    end

    # DELETE /api/v2/dashboard/id
    # Delete a specific dashboard.
    # Deleting an active dashboard moves it to 'trash', from where
    # it can be restored with an #undelete operation. Deleting a
    # dashboard in 'trash' removes it for ever.
    #
    # @param id [String] ID of the dashboard
    # @return [Wavefront::Response]
    #
    def delete(id)
      wf_dashboard_id?(id)
      api.delete(id)
    end

    # GET /api/v2/dashboard/id
    # Get a specific dashboard / Get a specific historical version
    # of a specific dashboard.
    #
    # @param id [String] ID of the dashboard
    # @param version [Integer] version of dashboard
    # @return [Wavefront::Response]
    #
    def describe(id, version = nil)
      wf_dashboard_id?(id)
      wf_version?(version) if version
      fragments = [id]
      fragments += ['history', version] if version
      api.get(fragments.uri_concat)
    end

    # PUT /api/v2/dashboard/id
    # Update a specific dashboard.
    #
    # @param id [String] a Wavefront alert ID
    # @param body [Hash] key-value hash of the parameters you wish
    #   to change
    # @param modify [true, false] if true, use {#describe()} to get
    #   a hash describing the existing object, and modify that with
    #   the new body. If false, pass the new body straight through.
    # @return [Wavefront::Response]

    def update(id, body, modify = true)
      wf_dashboard_id?(id)
      raise ArgumentError unless body.is_a?(Hash)

      return api.put(id, body, 'application/json') unless modify

      api.put(id, hash_for_update(describe(id).response, body),
              'application/json')
    end

    # POST /api/v2/dashboard/{id}/favorite
    # Mark a dashboard as favorite
    #
    # @param id [String] ID of the dashboard
    # @return [Wavefront::Response]
    #
    def favorite(id)
      wf_dashboard_id?(id)
      api.post([id, 'favorite'].uri_concat)
    end
    alias favourite favorite

    # GET /api/v2/dashboard/id/history
    # Get the version history of a dashboard.
    #
    # @param id [String] ID of the dashboard
    # @return [Wavefront::Response]
    #
    def history(id)
      wf_dashboard_id?(id)
      api.get([id, 'history'].uri_concat)
    end

    # POST /api/v2/dashboard/id/undelete
    # Move a dashboard from 'trash' back into active service.
    #
    # @param id [String] ID of the dashboard
    # @return [Wavefront::Response]
    #
    def undelete(id)
      wf_dashboard_id?(id)
      api.post([id, 'undelete'].uri_concat)
    end

    # POST /api/v2/dashboard/{id}/unfavorite
    # Unmark a dashboard as favorite
    #
    # @param id [String] ID of the dashboard
    # @return [Wavefront::Response]
    #
    def unfavorite(id)
      wf_dashboard_id?(id)
      api.post([id, 'unfavorite'].uri_concat)
    end
    alias unfavourite unfavorite

    def valid_id?(id)
      wf_dashboard_id?(id)
    end
  end
end
