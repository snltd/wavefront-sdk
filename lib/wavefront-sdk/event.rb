require_relative './base'

module Wavefront
  #
  # View and manage alerts. Events are identified by their millisecond
  # epoch timestamp.
  #
  class Event < Wavefront::Base

    # GET /api/v2/event
    # List all the events for a customer within a time range
    #
    # @param from [Time, Integer] start of time range. The API
    #   requires this time as epoch milliseconds, but we will also
    #   accept it as a Ruby Time object.
    # @param to [Time, Integer] end ot time range. Can be epoch
    #   millisecods or a Ruby time. If not supplied, defaults to the
    #   current time.
    # @cursor
    # @limit [Integer] the number of events to return
    # @return [Hash]
    #
    def list(from, to = nil, cursor, limit)
      api_get('', { offset: offset, limit: limit }.to_qs)
    end

    # Create a specific alert.
    # Refer to the Swagger API docs for valid keys.
    #
    # @param body [Hash] description of alert
    # @return [Hash]
    #
    def create(body)
      api_post('', body.to_json, 'application/json')
    end

    # Delete a specific alert.
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

    def update(id, body)
      wf_alert?(id)
      api_put(id, body)
    end

    # Get the version history of an alert
    #
    # @param id [String] ID of the alert
    # @return [Hash]
    #
    def history(id)
      wf_alert?(id)
      api_get([id, 'history'].uri_concat)
    end

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

    # Get all tags associated with a specific alert
    #
    # @param id [String] ID of the alert
    # @returns [Hash] object describing the alert with status and
    #   response keys
    #
    def tags(id)
      wf_alert?(id)
      api_get([id, 'tag'].uri_concat)
    end

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

    # Move an alert from 'trash' back into active service.
    #
    # @param id [String] ID of the alert
    # @return [Hash]
    #
    def undelete(id)
      wf_alert?(id)
      api_post([id, 'undelete'].uri_concat)
    end

    # Unsnooze an alert
    #
    # @param id [String] ID of the alert
    # @returns [Hash] object describing the alert with status and
    #   response keys
    #
    def unsnooze(id)
      wf_alert?(id)
      api_post([id, 'unsnooze'].uri_concat)
    end

    # Get a count of alerts in all possible states
    #
    # @return [Hash]
    #
    def summary
      api_get('summary')
    end
  end
end
