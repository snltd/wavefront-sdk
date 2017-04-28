require_relative './base'

module Wavefront
  #
  # View and manage events. Events are identified by their millisecond
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
    def list(from, to = nil, cursor = nil, limit = 100)
      api_get('', { earliestStartTimeEpochMillis: from,
                    latestStartTimeEpochMillis: to,
                    cursor: cursor,
                    limit: limit }.to_qs)
    end

    # Create a specific event.
    # Refer to the Swagger API docs for valid keys.
    #
    # @param body [Hash] description of events
    # @return [Hash]
    #
    def create(body)
      api_post('', body.to_json, 'application/json')
    end

    # Close a specific event.
    #
    # @param id [String] the ID of the event
    #
    def close(id)
      api_post([id, 'close'].uri_concat)
    end

    # Delete a specific event.
    #
    # @param id [String] ID of the alert
    # @return [Hash]
    #
    def delete(id)
      wf_event?(id)
      api_delete(id)
    end

    # Get a specific event / Get a specific historical version of a
    # specific event.
    #
    # @param id [String] ID of the event
    # @param version [Integer] version of event
    # @return [Hash]
    #
    def describe(id, version = nil)
      wf_event?(id)
      wf_version?(version) if version
      fragments = [id]
      fragments += ['history', version] if version
      api_get(fragments.uri_concat)
    end

    def update(id, body)
      wf_event?(id)
      api_put(id, body)
    end

    # Get all tags associated with a specific event
    #
    # @param id [String] ID of the event
    # @returns [Hash] object describing the event with status and
    #   response keys
    #
    def tags(id)
      wf_event?(id)
      api_get([id, 'tag'].uri_concat)
    end

    # Set all tags associated with a specific event.
    #
    # @param id [String] ID of the event
    # @param tags [Array] list of tags to set.
    # @returns [Hash] object describing the event with status and
    #   response keys
    #
    def tag_set(id, tags)
      wf_event?(id)
      tags = Array(tags)
      tags.each { |t| wf_string?(t) }
      api_post([id, 'tag'].uri_concat, tags.to_json, 'application/json')
    end

    # Add a tag to a specific event.
    #
    # @param id [String] ID of the event
    # @param tag [String] tag to set.
    # @returns [Hash] object with 'status' key and empty 'repsonse'
    #
    def tag_add(id, tag)
      wf_event?(id)
      wf_string?(tag)
      api_put([id, 'tag', tag].uri_concat)
    end

    # Remove a tag from a specific event.
    #
    # @param id [String] ID of the event
    # @param tag [String] tag to delete
    # @returns [Hash] object with 'status' key and empty 'repsonse'
    #
    def tag_delete(id, tag)
      wf_event?(id)
      wf_string?(tag)
      api_delete([id, 'tag', tag].uri_concat)
    end
  end
end
