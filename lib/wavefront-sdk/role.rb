# frozen_string_literal: true

require_relative 'core/api'
require_relative 'api_mixins/user'

module Wavefront
  #
  # Manage and query Wavefront roles
  #
  class Role < CoreApi
    include Wavefront::Mixin::User

    def update_keys
      %i[id name description]
    end

    # GET /api/v2/role
    # Get all roles for a customer
    # @param offset [Int] alert at which the list begins
    # @param limit [Int] the number of alerts to return
    # @return [Wavefront::Response]
    #
    def list(offset = 0, limit = 100)
      api.get('', offset: offset, limit: limit)
    end

    # POST /api/v2/role
    # Create a specific role
    # @param body [Hash] a hash of parameters describing the role.  Please
    #   refer to the Wavefront Swagger docs for key:value information
    # @return [Wavefront::Response]
    #
    def create(body)
      raise ArgumentError unless body.is_a?(Hash)

      api.post('', body, 'application/json')
    end

    # DELETE /api/v2/role/{id}
    # Delete a specific role
    # @param id [String] ID of the role
    # @return [Wavefront::Response]
    #
    def delete(id)
      wf_role_id?(id)
      api.delete(id)
    end

    # GET /api/v2/role/{id}
    # Get a specific role
    # @param id [String] ID of the role
    # @return [Wavefront::Response]
    #
    def describe(id)
      wf_role_id?(id)
      api.get(id)
    end

    # PUT /api/v2/role/{id}
    # Update a specific role
    # @param id [String] role ID
    # @param body [Hash] key-value hash of the parameters you wish to change
    # @param modify [true, false] if true, use {#describe()} to get a hash
    #   describing the existing object, and modify that with the new body. If
    #   false, pass the new body straight through.
    # @return [Wavefront::Response]
    #
    def update(id, body, modify = true)
      wf_role_id?(id)
      raise ArgumentError unless body.is_a?(Hash)

      return api.put(id, body, 'application/json') unless modify

      api.put(id, hash_for_update(describe(id).response, body),
              'application/json')
    end

    # POST /api/v2/role/{id}/addAssignees
    # Add multiple users and user groups to a specific role
    # @param id [String] role ID
    # @param assignees [Array[String]] list of roles or accounts to be added
    # @return [Wavefront::Response]
    #
    def add_assignees(id, assignees)
      wf_role_id?(id)
      validate_user_list(assignees)
      api.post([id, 'addAssignees'].uri_concat, assignees, 'application/json')
    end

    # POST /api/v2/role/{id}/removeAssignees
    # Remove multiple users and user groups from a specific role
    # @param id [String] role ID
    # @param assignees [Array[String]] list of roles or accounts to be removed
    # @return [Wavefront::Response]
    #
    def remove_assignees(id, assignees)
      wf_role_id?(id)
      validate_user_list(assignees)
      api.post([id, 'removeAssignees'].uri_concat,
               assignees,
               'application/json')
    end
  end
end
