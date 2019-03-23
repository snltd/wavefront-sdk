require_relative 'core/api'

module Wavefront
  #
  # Manage and query Wavefront customer settings. Corresponds to the
  # "system preferences" page in the UI.
  #
  class Settings < CoreApi
    def api_base
      '/customer'
    end

    # GET /api/v2/customer/permissions
    # Get all permissions
    #
    def permissions
      api.get(:permissions)
    end

    # GET /api/v2/customer/preferences
    # Get customer preferences
    #
    def preferences
      api.get(:preferences)
    end

    # POST /api/v2/customer/preferences
    # Update selected fields of customer preferences
    #
    # @param body [Hash] See the API documentation for the model
    #   schema. At the time of writing, permissible fields are
    #     showQuerybuilderByDefault [Bool]
    #     hideTSWhenQuerybuilderShown [Bool]
    #     landingDashboardSlug [String]
    #     showOnboarding [Bool]
    #     grantModifyAccessToEveryone [Bool]
    #     defaultUserGroups: [Array[String]]
    #     invitePermissions: [Array[String]]
    #
    def update_preferences(body)
      api.post(:preferences, body, 'application/json')
    end

    # GET /api/v2/customer/preferences/defaultUserGroups
    # Get default user groups customer preferences
    #
    def default_user_groups
      api.get('/preferences/defaultUserGroups')
    end
  end
end
