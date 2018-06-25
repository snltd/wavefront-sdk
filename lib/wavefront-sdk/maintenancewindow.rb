require_relative 'base'

module Wavefront
  #
  # Manage and query Wavefront maintenance windows
  #
  class MaintenanceWindow < Base
    def update_keys
      %i[reason title startTimeInSeconds endTimeInSeconds
         relevantCustomerTags relevantHostTags relevantHostNames]
    end

    # GET /api/v2/maintenancewindow
    # Get all maintenance windows for a customer.
    #
    # @param offset [Integer] window at which the list begins
    # @param limit [Integer] the number of window to return
    #
    def list(offset = 0, limit = 100)
      api_get('', offset: offset, limit: limit)
    end

    # POST /api/v2/maintenancewindow
    # Create a maintenance window.
    #
    # We used to validate input here but do not any more.
    #
    # @param body [Hash] a hash of parameters describing the window.
    #   Please refer to the Wavefront Swagger docs for key:value
    #   information
    # @return [Wavefront::Response]
    #
    def create(body)
      raise ArgumentError unless body.is_a?(Hash)
      api_post('', body, 'application/json')
    end

    # DELETE /api/v2/maintenancewindow/id
    # Delete a specific maintenance window.
    #
    # @param id [String, Integer] ID of the maintenance window
    # @return [Wavefront::Response]
    #
    def delete(id)
      wf_maintenance_window_id?(id)
      api_delete(id)
    end

    # GET /api/v2/maintenancewindow/id
    # Get a specific maintenance window.
    #
    # @param id [String, Integer] ID of the maintenance window
    # @return [Wavefront::Response]
    #
    def describe(id)
      wf_maintenance_window_id?(id)
      api_get(id)
    end

    # PUT /api/v2/maintenancewindow/id
    # Update a specific maintenance window.
    #
    # @param id [String] a Wavefront maintenance window ID
    # @param body [Hash] key-value hash of the parameters you wish
    #   to change
    # @param modify [true, false] if true, use {#describe()} to get
    #   a hash describing the existing object, and modify that with
    #   the new body. If false, pass the new body straight through.
    # @return [Wavefront::Response]

    def update(id, body, modify = true)
      wf_maintenance_window_id?(id)
      raise ArgumentError unless body.is_a?(Hash)

      return api_put(id, body, 'application/json') unless modify

      api_put(id, hash_for_update(describe(id).response, body),
              'application/json')
    end
  end
end
