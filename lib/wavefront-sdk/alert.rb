require_relative 'defs/constants'
require_relative 'core/api'
require_relative 'api_mixins/acl'
require_relative 'api_mixins/tag'

module Wavefront
  #
  # View and manage alerts. Alerts are identified by their millisecond
  # epoch timestamp. Returns a Wavefront::Response::Alert object.
  #
  class Alert < CoreApi
    include Wavefront::Mixin::Acl
    include Wavefront::Mixin::Tag

    def update_keys
      %i[id name target condition displayExpression minutes tag
         resolveAfterMinutes severity additionalInformation]
    end

    # GET /api/v2/alert
    # Get all alerts for a customer
    #
    # @param offset [Int] alert at which the list begins
    # @param limit [Int] the number of alerts to return
    # @return [Wavefront::Response]
    #
    def list(offset = 0, limit = 100)
      api.get('', offset: offset, limit: limit)
    end

    # POST /api/v2/alert
    # Create a specific alert. We used to validate input here, but
    # this couples the SDK too tightly to the API. Now it's just a
    # generic POST of a hash.
    #
    # @param body [Hash] description of alert
    # @return [Wavefront::Response]
    #
    def create(body)
      raise ArgumentError unless body.is_a?(Hash)
      api.post('', body, 'application/json')
    end

    # DELETE /api/v2/alert/id
    # Delete a specific alert.
    #
    # Deleting an active alert moves it to 'trash', from where it can
    # be restored with an #undelete operation. Deleting an alert in
    # 'trash' removes it for ever.
    #
    # @param id [String] ID of the alert
    # @return [Wavefront::Response]
    #
    def delete(id)
      wf_alert_id?(id)
      api.delete(id)
    end

    # GET /api/v2/alert/id
    # GET /api/v2/alert/id/history/version
    # Get a specific alert / Get a specific historical version of a
    # specific alert.
    #
    # @param id [String] ID of the alert
    # @param version [Integer] version of alert
    # @return [Wavefront::Response]
    #
    def describe(id, version = nil)
      wf_alert_id?(id)
      wf_version?(version) if version
      fragments = [id]
      fragments += ['history', version] if version
      api.get(fragments.uri_concat)
    end

    # Gets all the versions of the given alert
    # @param id [String] ID of the alert
    # @reutrn [Wavefront::Resonse] where items is an array of integers
    #
    def versions(id)
      wf_alert_id?(id)
      resp = api.get([id, 'history'].uri_concat)

      return if opts[:noop]

      versions = resp.response.items.map(&:version)
      resp.response[:items] = versions
      resp
    end

    # PUT /api/v2/alert/id
    # Update a specific alert.
    #
    # @param id [String] a Wavefront alert ID
    # @param body [Hash] key-value hash of the parameters you wish
    #   to change
    # @param modify [true, false] if true, use {#describe()} to get
    #   a hash describing the existing object, and modify that with
    #   the new body. If false, pass the new body straight through.
    # @return [Wavefront::Response]

    def update(id, body, modify = true)
      wf_alert_id?(id)
      raise ArgumentError unless body.is_a?(Hash)

      return api.put(id, body, 'application/json') unless modify

      api.put(id, hash_for_update(describe(id).response, body),
              'application/json')
    end

    # POST /api/v2/alert/{id}/clone
    # Clones the specified alert
    # @param id [String] ID of the alert
    # @param version [Integer] version of alert
    # @return [Wavefront::Response]
    #
    def clone(id, version = nil)
      wf_alert_id?(id)
      wf_version?(version) if version

      api.post([id, 'clone'].uri_concat,
               { id:   id,
                 name: nil,
                 v:    version }, 'application/json')
    end

    # GET /api/v2/alert/id/history
    # Get the version history of a specific alert.
    #
    # @param id [String] ID of the alert
    # @return [Wavefront::Response]
    #
    def history(id, offset = nil, limit = nil)
      wf_alert_id?(id)
      qs = {}
      qs[:offset] = offset if offset
      qs[:limit] = limit if limit

      api.get([id, 'history'].uri_concat, qs)
    end

    # POST /api/v2/alert/{id}/install
    # Unhide a specific integration alert
    #
    def install(id)
      wf_alert_id?(id)
      api.post([id, 'install'].uri_concat, nil)
    end

    # POST /api/v2/alert/id/snooze
    # Snooze a specific alert for some number of seconds.
    #
    # @param id [String] ID of the alert
    # @param seconds [Integer] how many seconds to snooze for.
    #   Nil is indefinite.
    # @return [Wavefront::Response]
    #
    def snooze(id, seconds = nil)
      wf_alert_id?(id)
      qs = seconds ? "?seconds=#{seconds}" : ''
      api.post([id, "snooze#{qs}"].uri_concat, nil)
    end

    def valid_id?(id)
      wf_alert_id?(id)
    end

    # POST /api/v2/alert/id/undelete
    # Undelete a specific alert.
    #
    # @param id [String] ID of the alert
    # @return [Wavefront::Response]
    #
    def undelete(id)
      wf_alert_id?(id)
      api.post([id, 'undelete'].uri_concat)
    end

    # POST /api/v2/alert/{id}/uninstall
    # Hide a specific integration alert
    #
    def uninstall(id)
      wf_alert_id?(id)
      api.post([id, 'uninstall'].uri_concat, nil)
    end

    # POST /api/v2/alert/id/unsnooze
    # Unsnooze a specific alert.
    #
    # @param id [String] ID of the alert
    # @return [Wavefront::Response]
    #
    def unsnooze(id)
      wf_alert_id?(id)
      api.post([id, 'unsnooze'].uri_concat)
    end

    # GET /api/v2/alert/summary
    # Count alerts of various statuses for a customer
    #
    # @return [Wavefront::Response]
    #
    def summary
      api.get('summary')
    end

    # The following methods replicate similarly named ones in the v1
    # SDK. The v2 API does not provide the level of alert-querying
    # convenience v1 did, but we can still give our users those
    # lovely simple methods. Note that these are constructions of
    # the SDK and do not actually correspond to the underlying API.

    # @return [Wavefront::Response] all alerts which have an invalid
    #   query.
    #
    def invalid
      alerts_in_state(:invalid)
    end

    # For completeness, one-word methods like those above for all
    # possible alert states.

    # @return [Wavefront::Response] all alerts currently snoozed
    #
    def snoozed
      alerts_in_state(:snoozed)
    end

    # @return [Wavefront::Response] all currently firing alerts.
    #
    def firing
      alerts_in_state(:firing)
    end
    alias active firing

    # @return [Wavefront::Response] all alerts currently in a
    #   maintenance window.
    #
    def in_maintenance
      alerts_in_state(:in_maintenance)
    end
    alias affected_by_maintenance in_maintenance

    # @return [Wavefront::Response] I honestly don't know what the
    #   NONE state denotes, but this will fetch alerts which have
    #   it.
    #
    def none
      alerts_in_state(:none)
    end

    # @return [Wavefront::Response] all alerts being checked.
    #
    def checking
      alerts_in_state(:checking)
    end

    # @return [Wavefront::Response] all alerts in the trash.
    #
    def trash
      alerts_in_state(:trash)
    end

    # @return [Wavefront::Response] all alerts reporting NO_DATA.
    #
    def no_data
      alerts_in_state(:no_data)
    end

    # @return [Wavefront::Response] all your alerts
    #
    def all
      list(PAGE_SIZE, :all)
    end

    # Use a search to get all alerts in the given state. You would
    # be better to use one of the wrapper methods like #firing,
    # #snoozed etc, but I've left this method public in case new
    # states are added before the SDK supports them.
    # @param state [Symbol] state such as :firing, :snoozed etc. See
    #   the Alert Swagger documentation for a full list
    # @return [Wavfront::Response]
    #
    def alerts_in_state(state)
      require_relative 'search'
      wfs = Wavefront::Search.new(creds, opts)
      query = { key: 'status', value: state, matchingMethod: 'EXACT' }
      wfs.search(:alert, query, limit: :all, offset: PAGE_SIZE)
    end
  end
end
