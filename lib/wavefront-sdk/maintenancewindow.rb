require_relative 'core/api'

module Wavefront
  #
  # Manage and query Wavefront maintenance windows
  #
  class MaintenanceWindow < CoreApi
    def update_keys
      %i[id reason title startTimeInSeconds endTimeInSeconds
         relevantCustomerTags relevantHostTags relevantHostNames]
    end

    # GET /api/v2/maintenancewindow
    # Get all maintenance windows for a customer.
    #
    # @param offset [Integer] window at which the list begins
    # @param limit [Integer] the number of window to return
    #
    def list(offset = 0, limit = 100)
      api.get('', offset: offset, limit: limit)
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
      api.post('', body, 'application/json')
    end

    # DELETE /api/v2/maintenancewindow/id
    # Delete a specific maintenance window.
    #
    # @param id [String, Integer] ID of the maintenance window
    # @return [Wavefront::Response]
    #
    def delete(id)
      wf_maintenance_window_id?(id)
      api.delete(id)
    end

    # GET /api/v2/maintenancewindow/id
    # Get a specific maintenance window.
    #
    # @param id [String, Integer] ID of the maintenance window
    # @return [Wavefront::Response]
    #
    def describe(id)
      wf_maintenance_window_id?(id)
      api.get(id)
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

      return api.put(id, body, 'application/json') unless modify

      api.put(id, hash_for_update(describe(id).response, body),
              'application/json')
    end

    # Windows currently open.
    # @return [Wavefront::Response]
    #
    def ongoing
      windows_in_state(:ongoing)
    end

    # Get the windows which will be open in the next so-many hours
    # @param hours [Numeric] how many hours to look ahead
    # @return [Wavefront::Response]
    #
    def pending(hours = 24)
      cutoff = Time.now.to_i + hours * 3600

      ret = windows_in_state(:pending)

      return if opts[:noop]

      ret.tap do |r|
        r.response.items.delete_if { |w| w.startTimeInSeconds > cutoff }
      end
    end

    # This method mimics the similarly named method from the v1 SDK,
    # which called the 'GET /api/alert/maintenancewindow/summary'
    # path.
    # @return [Wavefront::Response]
    #
    def summary
      ret = pending

      items = { UPCOMING: ret.response.items,
                CURRENT:  ongoing.response.items }

      ret.response.items = items
      ret
    end

    # Return all maintenance windows in the given state. At the time
    # of writing valid states are ONGOING, PENDING, and ENDED.
    # @param state [Symbol]
    # @return [Wavefront::Response]
    #
    def windows_in_state(state)
      require_relative 'search'
      wfs = Wavefront::Search.new(creds, opts)
      query = { key: 'runningState', value: state, matchingMethod: 'EXACT' }
      wfs.search(:maintenancewindow, query, limit: :all, offset: PAGE_SIZE)
    end
  end
end
