# frozen_string_literal: true

require_relative 'core/api'
require_relative 'api_mixins/user'

module Wavefront
  #
  # In line with the API changes in the 2020-06 release of Wavefront, this
  # class has been deprecated.
  #
  # Please use Wavefront::Account to manage users.
  #
  # https://docs.wavefront.com/2020.06.x_release_notes.html
  #
  # Manage and query Wavefront users
  #
  class User < CoreApi
    include Wavefront::Mixin::User

    def deprecation_warning
      logger.log('Wavefront::User is deprecated and will be removed from the ' \
                 'next major release. Please use Wavefront::Account.', :warn)
    end

    def post_initialize(_creds, _opts)
      deprecation_warning
    end

    # GET /api/v2/user
    # Get all users.
    #
    def list
      deprecation_warning
      api.get('')
    end

    # POST /api/v2/user
    # Creates or updates a user
    #
    # @param body [Hash] a hash of parameters describing the user.
    #   Please refer to the Wavefront Swagger docs for key:value
    #   information
    # @return [Wavefront::Response]
    #
    def create(body, send_email = false)
      deprecation_warning
      raise ArgumentError unless body.is_a?(Hash)

      api.post("?sendEmail=#{send_email}", body, 'application/json')
    end

    # DELETE /api/v2/user/id
    # Delete a specific user. See also #delete_users.
    #
    # @param id [String] ID of the user
    # @return [Wavefront::Response]
    #
    def delete(id)
      deprecation_warning
      wf_user_id?(id)
      api.delete(id)
    end

    # GET /api/v2/user/id
    # Retrieves a user by identifier (email addr).
    #
    # @param id [String] ID of the user
    # @return [Wavefront::Response]
    #
    def describe(id)
      deprecation_warning
      wf_user_id?(id)
      api.get(id)
    end

    # PUT /api/v2/user/id
    # Update a specific user definition.
    #
    # @param id [String] a Wavefront user ID
    # @param body [Hash] key-value hash of the parameters you wish
    #   to change
    # @param modify [true, false] if true, use {#describe()} to get
    #   a hash describing the existing object, and modify that with
    #   the new body. If false, pass the new body straight through.
    # @return [Wavefront::Response]

    def update(id, body, modify = true)
      deprecation_warning
      wf_user_id?(id)
      raise ArgumentError unless body.is_a?(Hash)

      return api.put(id, body, 'application/json') unless modify

      api.put(id, hash_for_update(describe(id).response, body),
              'application/json')
    end

    # POST /api/v2/user/{id}/addUserGroups
    # Adds specific user groups to the user
    #
    # @param id [String] ID of the user
    # @param group_list [Array[String]] list of groups to add
    # @return [Wavefront::Response]
    #
    def add_groups_to_user(id, group_list = [])
      deprecation_warning
      wf_user_id?(id)
      validate_usergroup_list(group_list)
      api.post([id, 'addUserGroups'].uri_concat, group_list,
               'application/json')
    end

    # POST /api/v2/user/{id}/removeUserGroups
    # Removes specific user groups from the user
    # @param id [String] ID of the user
    # @param group_list [Array[String]] list of groups to remove
    # @return [Wavefront::Response]
    #
    def remove_groups_from_user(id, group_list = [])
      deprecation_warning
      wf_user_id?(id)
      validate_usergroup_list(group_list)
      api.post([id, 'removeUserGroups'].uri_concat, group_list,
               'application/json')
    end

    # PUT /api/v2/user/id/grant
    # Grants a specific user permission.
    #
    # @param id [String] ID of the user
    # @param pgroup [String] permission group to grant to user. We
    #   do not validate this so that changes to the API do not mandate
    #   changes to the SDK. At the time of writing, valid values are
    #   browse,
    #   agent_management, alerts_management, dashboard_management,
    #   embedded_charts, events_management,
    #   external_links_management, host_tag_management,
    #   metrics_management, user_management,
    # @return [Wavefront::Response]
    #
    def grant(id, pgroup)
      deprecation_warning
      wf_user_id?(id)
      raise ArgumentError unless pgroup.is_a?(String)

      api.post([id, 'grant'].uri_concat, "group=#{pgroup}",
               'application/x-www-form-urlencoded')
    end

    # PUT /api/v2/user/id/revoke
    # Revokes a specific user permission.
    #
    # @param id [String] ID of the user
    # @param pgroup [String] permission group to revoke from the
    #   user. We do not validate this so that changes to the API do
    #   not mandate changes to the SDK. See #update for valid values.
    # @return [Wavefront::Response]
    #
    def revoke(id, pgroup)
      deprecation_warning
      wf_user_id?(id)
      raise ArgumentError unless pgroup.is_a?(String)

      api.post([id, 'revoke'].uri_concat, "group=#{pgroup}",
               'application/x-www-form-urlencoded')
    end

    # POST /api/v2/user/deleteUsers
    # Deletes multiple users
    #
    # Yep, a POST that DELETEs. Not to be confused with DELETE. I
    # don't make the API, I just cover it.
    # @param user_list [Array[String]] list of user IDs
    # @return [Wavefront::Response]
    #
    def delete_users(user_list)
      deprecation_warning
      raise ArgumentError unless user_list.is_a?(Array)

      validate_user_list(user_list)
      api.post('deleteUsers', user_list, 'application/json')
    end

    # POST /api/v2/user/grant/{permission}
    # Grants a specific user permission to multiple users
    # See #grant for possible permissions. This method operates on
    # multiple users.
    # @param permission [String] permission to grant
    # @param user_list [Array[String]] users who should receive the
    #   permission
    # @return [Wavefront::Response]
    #
    def grant_permission(permission, user_list)
      deprecation_warning
      raise ArgumentError unless user_list.is_a?(Array)

      validate_user_list(user_list)
      api.post(['grant', permission].uri_concat, user_list,
               'application/json')
    end

    # POST /api/v2/user/revoke/{permission}
    # Revokes a specific user permission from multiple users
    # See #grant for possible permissions. This method operates on
    # multiple users.
    # @param permission [String] permission to revoke
    # @param user_list [Array[String]] users who should lose the
    #   permission
    # @return [Wavefront::Response]
    #
    def revoke_permission(permission, user_list)
      deprecation_warning
      raise ArgumentError unless user_list.is_a?(Array)

      validate_user_list(user_list)
      api.post(['revoke', permission].uri_concat, user_list,
               'application/json')
    end

    # POST /api/v2/user/invite
    # Invite users with given user groups and permissions.
    # @param body [Array[Hash]] array of hashes describing a user.
    #   See API docs for more details.
    # @return [Wavefront::Response]
    #
    def invite(body)
      deprecation_warning
      raise ArgumentError unless body.is_a?(Array)
      raise ArgumentError unless body.first.is_a?(Hash)

      api.post('invite', body, 'application/json')
    end

    # GET /api/v2/user/{id}/businessFunctions
    # Returns business functions of a specific user.
    # @param id [String] user ID
    # @return [Wavefront::Response]
    #
    def business_functions(id)
      deprecation_warning
      wf_user_id?(id)
      api.get([id, 'businessFunctions'].uri_concat)
    end

    # POST /api/v2/user/validateUsers
    # Returns valid users and service accounts, also invalid identifiers from
    # the given list
    # @param id_list [Array[String]] list of user IDs
    # @return [Wavefront::Response]
    #
    def validate_users(id_list)
      deprecation_warning
      api.post('validateUsers', id_list, 'application/json')
    end

    # Fake a response which looks like we get from all the other
    # paths. I'm expecting the user response model to be made
    # consistent with others in the future.
    # @return [String] of JSON
    #
    def response_shim(body, status)
      body_obj = JSON.parse(body, symbolize_names: true)

      if body_obj.is_a?(Hash) && body_obj.key?(:status)
        if response_looks_right?(body_obj)
          body
        else
          itemize_response(body_obj)
        end
      else
        construct_response(body_obj, status)
      end
    end

    def itemize_response(body_obj)
      { status: body_obj[:status],
        response: { items: [body_obj[:response]].flatten } }.to_json
    end

    # Construct a response almost from scratch. Used for 'list', among others.
    #
    def construct_response(body_obj, status)
      { status: { result: status.to_s.start_with?('2') ? 'OK' : 'ERROR',
                  message: extract_api_message(status, body_obj),
                  code: status },
        response: { items: [body_obj].flatten,
                    offset: 0,
                    limit: body_obj.size,
                    totalItems: body_obj.size,
                    moreItems: false } }.to_json
    end

    # the user API class does not support pagination. Be up-front
    # about that.
    #
    def everything
      raise NoMethodError
    end

    def update_keys
      %i[identifier groups userGroups]
    end

    private

    def response_looks_right?(body_obj)
      body_obj.key?(:response) &&
        body_obj[:response].is_a?(Hash) &&
        body_obj[:response].key?(:items) &&
        body_obj[:response][:items].is_a?(Array)
    end

    def extract_api_message(status, items)
      return '' if status < 300

      items.fetch(:message, 'no message from API')
    end
  end
end
