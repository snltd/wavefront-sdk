require_relative './base'

module Wavefront
  #
  # Manage and query Wavefront maintenance windows
  #
  class MaintenanceWindow < Base

    # GET /api/v2/maintenancewindow
    # Get all maintenance windows for a customer.
    #
    # @param offset [Integer] window at which the list begins
    # @param limit [Integer] the number of window to return
    #
    def list(offset = 0, limit = 100)
      api_get('', { offset: offset, limit: limit })
    end

    # POST /api/v2/maintenancewindow
    # Create a maintenance window.
    #
    # We used to validate input here but do not any more.
    #
    # @param body [Hash] a hash of parameters describing the window.
    #   Please refer to the Wavefront Swagger docs for key:value
    #   information
    # @return [Hash]
    #
    def create(body)
      raise ArgumentError unless body.is_a?(Hash)
      api_post('', body, 'application/json')
    end

    # DELETE /api/v2/maintenancewindow/id
    # Delete a specific maintenance window.
    #
    # @param id [String, Integer] ID of the maintenance window
    # @return [Hash]
    #
    def delete(id)
      wf_maintenance_window_id?(id)
      api_delete(id)
    end

    # GET /api/v2/maintenancewindow/id
    # Get a specific maintenance window.
    #
    # @param id [String, Integer] ID of the maintenance window
    # @return [Hash]
    #
    def describe(id)
      wf_maintenance_window_id?(id)
      api_get(id)
    end

    # PUT /api/v2/maintenancewindow/id
    # Update a specific maintenance window.
    #
    # @param body [Hash] a hash of parameters describing the window.
    # @return [Hash]
    # @raise any validation errors from body
    #
    def update(id, body)
      wf_maintenance_window_id?(id)
      raise ArgumentError unless body.is_a?(Hash)
      api_put(id, body)
    end
  end
end
