require_relative './base'

module Wavefront
  #
  # Manage and query Wavefront users
  #
  class User < Base

    # GET /api/v2/user
    # Get all users.
    #
    def list
      api_get('')
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
      raise ArgumentError unless body.is_a?(Hash)
      api_post("?sendEmail=#{send_email}", body, 'application/json')
    end

    # DELETE /api/v2/user/id
    # Delete a specific user.
    #
    # @param id [String] ID of the user
    # @return [Wavefront::Response]
    #
    def delete(id)
      wf_user_id?(id)
      api_delete(id)
    end

    # GET /api/v2/user/id
    # Retrieves a user by identifier (email addr).
    #
    # @param id [String] ID of the user
    # @return [Wavefront::Response]
    #
    def describe(id)
      wf_user_id?(id)
      api_get(id)
    end

    # PUT /api/v2/user/id/grant
    # Grants a specific user permission.
    #
    # @param id [String] ID of the user
    # @param group [String] group to add user to. We do not validate
    #   this so that changes to the API do not mandate changes to
    #   the SDK. At the time of writing, valid values are browse,
    #   agent_management, alerts_management, dashboard_management,
    #   embedded_charts, events_management,
    #   external_links_management, host_tag_management,
    #   metrics_management, user_management,
    # @return [Wavefront::Response]
    #
    def grant(id, group)
      wf_user_id?(id)
      raise ArgumentError unless group.is_a?(String)
      api_post([id, 'grant'].uri_concat, "group=#{group}",
               'application/x-www-form-urlencoded')
    end

    # PUT /api/v2/user/id/revoke
    # Revokes a specific user permission.
    #
    # @param id [String] ID of the user
    # @param group [String] group to add user to. We do not validate
    #   this so that changes to the API do not mandate changes to
    #   the SDK. See #update for valid values.
    # @return [Wavefront::Response]
    #
    def revoke(id, group)
      wf_user_id?(id)
      raise ArgumentError unless group.is_a?(String)
      api_post([id, 'revoke'].uri_concat, "group=#{group}",
               'application/x-www-form-urlencoded')
    end

    # Fake a response which looks like we get from all the other
    # paths. I'm expecting the user response model to be made
    # consistent with others in the future.
    #
    def response_shim(body, status)
      { response: JSON.parse(body),
        status:   { result:  status == 200 ? 'OK' : 'ERROR',
                    message: '',
                    code:    status },
      }.to_json
    end
  end
end
