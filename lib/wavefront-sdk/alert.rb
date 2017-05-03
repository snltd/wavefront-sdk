require_relative './base'

module Wavefront
  #
  # View and manage alerts. Alerts are identified by their millisecond
  # epoch timestamp.
  #
  class Alert < Wavefront::Base

    # GET /api/v2/alert
    # Get all alerts for a customer
    #
    # @param offset [Int] alert at which the list begins
    # @param limit [Int] the number of alerts to return
    # @return [Hash]
    #
    def list(offset = 0, limit = 100)
      api_get('', { offset: offset, limit: limit })
    end

    # POST /api/v2/alert
    # Create a specific alert. We used to validate input here, but
    # this couples the SDK too tightly to the API. Now it's just a
    # generic POST of a hash.
    #
    # @param body [Hash] description of alert
    # @return [Hash]
    #
    def create(body)
      raise ArgumentError unless body.is_a?(Hash)
      api_post('', body, 'application/json')
    end

    # DELETE /api/v2/alert/{id}
    # Delete a specific alert.
    #
    # Deleting an active alert moves it to 'trash', from where it can
    # be restored with an #undelete operation. Deleting an alert in
    # 'trash' removes it for ever.
    #
    # @param id [String] ID of the alert
    # @return [Hash]
    #
    def delete(id)
      wf_alert?(id)
      api_delete(id)
    end

    # GET /api/v2/alert/{id}
    # GET /api/v2/alert/{id}/history/{version}
    # Get a specific alert / Get a specific historical version of a
    # specific alert.
    #
    # @param id [String] ID of the alert
    # @param version [Integer] version of alert
    # @return [Hash]
    #
    def describe(id, version = nil)
      wf_alert?(id)
      wf_version?(version) if version
      fragments = [id]
      fragments += ['history', version] if version
      api_get(fragments.uri_concat)
    end

    # PUT /api/v2/alert/{id}
    # Update a specific alert.
    #
    # @param id [String] a Wavefront alert ID
    # @param body [Hash] description of event. See body_desc()
    # @return [Hash]
    #
    def update(id, body)
      wf_alert?(id)
      raise ArgumentError unless body.is_a?(Hash)
      api_put(id, body, 'application/json')
    end

    # GET /api/v2/alert/{id}/history
    # Get the version history of a specific alert.
    #
    # @param id [String] ID of the alert
    # @return [Hash]
    #
    def history(id)
      wf_alert?(id)
      api_get([id, 'history'].uri_concat)
    end

    # POST /api/v2/alert/{id}/snooze
    # Snooze a specific alert for some number of seconds.
    #
    # @param id [String] ID of the alert
    # @param time [Integer] how many seconds to snooze for
    # @returns [Hash] object describing the alert with status and
    #   response keys
    #
    def snooze(id, time = 3600)
      wf_alert?(id)
      api_post([id, 'snooze'].uri_concat, time)
    end

    # GET /api/v2/alert/{id}/tag
    # Get all tags associated with a specific alert.
    #
    # @param id [String] ID of the alert
    # @returns [Hash] object describing the alert with status and
    #   response keys
    #
    def tags(id)
      wf_alert?(id)
      api_get([id, 'tag'].uri_concat)
    end

    # POST /api/v2/alert/{id}/tag
    # Set all tags associated with a specific alert.
    #
    # @param id [String] ID of the alert
    # @param tags [Array] list of tags to set.
    # @returns [Hash] object describing the alert with status and
    #   response keys
    #
    def tag_set(id, tags)
      wf_alert?(id)
      tags = Array(tags)
      tags.each { |t| wf_string?(t) }
      api_post([id, 'tag'].uri_concat, tags.to_json, 'application/json')
    end

    # DELETE /api/v2/alert/{id}/tag/{tagValue}
    # Remove a tag from a specific alert.
    #
    # @param id [String] ID of the alert
    # @param tag [String] tag to delete
    # @returns [Hash] object with 'status' key and empty 'repsonse'
    #
    def tag_delete(id, tag)
      wf_alert?(id)
      wf_string?(tag)
      api_delete([id, 'tag', tag].uri_concat)
    end

    # PUT /api/v2/alert/{id}/tag/{tagValue}
    # Add a tag to a specific alert.
    #
    # @param id [String] ID of the alert
    # @param tag [String] tag to set.
    # @returns [Hash] object with 'status' key and empty 'repsonse'
    #
    def tag_add(id, tag)
      wf_alert?(id)
      wf_string?(tag)
      api_put([id, 'tag', tag].uri_concat)
    end

    # POST /api/v2/alert/{id}/undelete
    # Undelete a specific alert.
    #
    # @param id [String] ID of the alert
    # @return [Hash]
    #
    def undelete(id)
      wf_alert?(id)
      api_post([id, 'undelete'].uri_concat)
    end

    # POST /api/v2/alert/{id}/unsnooze
    # Unsnooze a specific alert.
    #
    # @param id [String] ID of the alert
    # @returns [Hash] object describing the alert with status and
    #   response keys
    #
    def unsnooze(id)
      wf_alert?(id)
      api_post([id, 'unsnooze'].uri_concat)
    end

    # GET /api/v2/alert/summary
    # Count alerts of various statuses for a customer
    #
    # @return [Hash]
    #
    def summary
      api_get('summary')
    end
  end
end
