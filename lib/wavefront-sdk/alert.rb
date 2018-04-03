require_relative './base'

module Wavefront
  #
  # View and manage alerts. Alerts are identified by their millisecond
  # epoch timestamp. Returns a Wavefront::Response::Alert object.
  #
  class Alert < Base
    def update_keys
      %i[id name target condition displayExpression minutes
         resolveAfterMinutes severity additionalInformation]
    end

    # GET /api/v2/alert
    # Get all alerts for a customer
    #
    # @param offset [Int] alert at which the list begins
    # @param limit [Int] the number of alerts to return
    # @return [Hash]
    #
    def list(offset = 0, limit = 100)
      api_get('', offset: offset, limit: limit)
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
      api_post('', body, 'application/json')
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
      api_delete(id)
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
      api_get(fragments.uri_concat)
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

      return api_put(id, body, 'application/json') unless modify

      api_put(id, hash_for_update(describe(id).response, body),
              'application/json')
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

      api_get([id, 'history'].uri_concat, qs)
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
      api_post([id, "snooze#{qs}"].uri_concat, nil)
    end

    # GET /api/v2/alert/id/tag
    # Get all tags associated with a specific alert.
    #
    # @param id [String] ID of the alert
    # @return [Wavefront::Response]
    #
    def tags(id)
      wf_alert_id?(id)
      api_get([id, 'tag'].uri_concat)
    end

    # POST /api/v2/alert/id/tag
    # Set all tags associated with a specific alert.
    #
    # @param id [String] ID of the alert
    # @param tags [Array] list of tags to set.
    # @return [Wavefront::Response]
    #
    def tag_set(id, tags)
      wf_alert_id?(id)
      tags = Array(tags)
      tags.each { |t| wf_string?(t) }
      api_post([id, 'tag'].uri_concat, tags.to_json, 'application/json')
    end

    # DELETE /api/v2/alert/id/tag/tagValue
    # Remove a tag from a specific alert.
    #
    # @param id [String] ID of the alert
    # @param tag [String] tag to delete
    # @return [Wavefront::Response]
    #
    def tag_delete(id, tag)
      wf_alert_id?(id)
      wf_string?(tag)
      api_delete([id, 'tag', tag].uri_concat)
    end

    # PUT /api/v2/alert/id/tag/tagValue
    # Add a tag to a specific alert.
    #
    # @param id [String] ID of the alert
    # @param tag [String] tag to set.
    # @return [Wavefront::Response]
    #
    def tag_add(id, tag)
      wf_alert_id?(id)
      wf_string?(tag)
      api_put([id, 'tag', tag].uri_concat)
    end

    # POST /api/v2/alert/id/undelete
    # Undelete a specific alert.
    #
    # @param id [String] ID of the alert
    # @return [Wavefront::Response]
    #
    def undelete(id)
      wf_alert_id?(id)
      api_post([id, 'undelete'].uri_concat)
    end

    # POST /api/v2/alert/id/unsnooze
    # Unsnooze a specific alert.
    #
    # @param id [String] ID of the alert
    # @return [Wavefront::Response]
    #
    def unsnooze(id)
      wf_alert_id?(id)
      api_post([id, 'unsnooze'].uri_concat)
    end

    # GET /api/v2/alert/summary
    # Count alerts of various statuses for a customer
    #
    # @return [Wavefront::Response]
    #
    def summary
      api_get('summary')
    end
  end
end
