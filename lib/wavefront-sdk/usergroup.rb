# frozen_string_literal: true

require_relative 'core/api'
require_relative 'api_mixins/user'

module Wavefront
  #
  # Manage and query Wavefront user groups
  #
  class UserGroup < CoreApi
    include Wavefront::Mixin::User

    def update_keys
      %i[id name]
    end

    # GET /api/v2/usergroup
    # Get all user groups for a customer
    # @param offset [Int] usergroup at which the list begins
    # @param limit [Int] the number of usergroups to return
    # @return [Wavefront::Response]
    #
    def list(offset = 0, limit = 100)
      api.get('', offset: offset, limit: limit)
    end

    # POST /api/v2/usergroup
    # Create a specific user group
    #
    # @param body [Hash] a hash of parameters describing the group.
    #   Please refer to the Wavefront Swagger docs for key:value
    #   information
    # @return [Wavefront::Response]
    #
    def create(body)
      raise ArgumentError unless body.is_a?(Hash)

      api.post('', body, 'application/json')
    end

    # DELETE /api/v2/usergroup/{id}
    # Delete a specific user group
    #
    # @param id [String] ID of the user group
    # @return [Wavefront::Response]
    #
    def delete(id)
      wf_usergroup_id?(id)
      api.delete(id)
    end

    # GET /api/v2/usergroup/{id}
    # Get a specific user group
    #
    # @param id [String] ID of the user group
    # @return [Wavefront::Response]
    #
    def describe(id)
      wf_usergroup_id?(id)
      api.get(id)
    end

    # PUT /api/v2/usergroup/{id}
    # Update a specific user group
    #
    # @param id [String] a Wavefront usergroup ID
    # @param body [Hash] key-value hash of the parameters you wish
    #   to change
    # @param modify [true, false] if true, use {#describe()} to get
    #   a hash describing the existing object, and modify that with
    #   the new body. If false, pass the new body straight through.
    # @return [Wavefront::Response]

    def update(id, body, modify = true)
      wf_usergroup_id?(id)
      raise ArgumentError unless body.is_a?(Hash)

      return api.put(id, body, 'application/json') unless modify

      api.put(id, hash_for_update(describe(id).response, body),
              'application/json')
    end

    # POST /api/v2/usergroup/{id}/addUsers
    # Add multiple users to a specific user group
    #
    # @param id [String] ID of the user group
    # @param user_list [Array[String]] list of users to add
    # @return [Wavefront::Response]
    #
    def add_users_to_group(id, user_list = [])
      wf_usergroup_id?(id)
      validate_user_list(user_list)
      api.post([id, 'addUsers'].uri_concat, user_list, 'application/json')
    end

    # POST /api/v2/usergroup/{id}/removeUsers
    # Remove multiple users from a specific user group
    #
    # @param id [String] ID of the user group
    # @param user_list [Array[String]] list of users to remove
    # @return [Wavefront::Response]
    #
    def remove_users_from_group(id, user_list = [])
      wf_usergroup_id?(id)
      validate_user_list(user_list)
      api.post([id, 'removeUsers'].uri_concat, user_list,
               'application/json')
    end

    # POST /api/v2/usergroup/{id}/addRoles
    # Add multiple roles to a specific user group
    #
    # @param id [String] ID of the user group
    # @param role_list [Array[String]] list of roles to add
    # @return [Wavefront::Response]
    #
    def add_roles_to_group(id, role_list = [])
      wf_usergroup_id?(id)
      validate_role_list(role_list)
      api.post([id, 'addRoles'].uri_concat, role_list, 'application/json')
    end

    # POST /api/v2/usergroup/{id}/removeRoles
    # Remove multiple roles from a specific user group
    #
    # @param id [String] ID of the user group
    # @param user_list [Array[String]] list of roles to remove
    # @return [Wavefront::Response]
    #
    def remove_roles_from_group(id, role_list = [])
      wf_usergroup_id?(id)
      validate_role_list(role_list)
      api.post([id, 'removeRoles'].uri_concat, role_list,
               'application/json')
    end
  end
end
