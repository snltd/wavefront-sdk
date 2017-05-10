require_relative './base'

module Wavefront
  #
  # View and manage events. Events are identified by their millisecond
  # epoch timestamp.
  #
  class Event < Wavefront::Base
    @update_keys = [:startTime, :endTime, :name, :annotations]

    # GET /api/v2/event
    # List all the events for a customer within a time range.
    #
    # @param from [Time, Integer] start of time range. The API
    #   requires this time as epoch milliseconds, but we will also
    #   accept it as a Ruby Time object.
    # @param to [Time, Integer] end ot time range. Can be epoch
    #   millisecods or a Ruby time. If not supplied, defaults to the
    #   current time.
    # @cursor [String] I think this is the 
    #   must start with a timestamp.
    # @limit [Integer] the number of events to return
    # @return [Hash]
    #
    def list(from = nil, to = nil, limit = 100, cursor = nil)
      raise ArgumentError unless from && to
      from = parse_time(from, true)
      to = parse_time(to, true)
      wf_ms_ts?(from)
      wf_ms_ts?(to)
      wf_event_id?(cursor) if cursor
      raise ArgumentError unless limit.is_a?(Integer)

      api_get('', { earliestStartTimeEpochMillis: from,
                    latestStartTimeEpochMillis: to,
                    cursor: cursor,
                    limit: limit }.select { |_k, v| v })
    end

    # POST /api/v2/event
    # Create a specific event.
    #
    # We used to validate keys and provide helpers for time fields.
    # Now ensuring a valid hash is entirely left up to the user.
    # Refer to the Swagger docs for more information.
    #
    # @param body [Hash] description of event
    # @return [Hash]
    #
    def create(body)
      raise ArgumentError unless body.is_a?(Hash)
      api_post('', body, 'application/json')
    end

    # DELETE /api/v2/event/{id}
    # Delete a specific event.
    #
    # @param id [String] ID of the alert
    # @return [Hash]
    #
    def delete(id)
      wf_event_id?(id)
      api_delete(id)
    end

    # GET /api/v2/event/{id}
    # Get a specific event / Get a specific historical version of a
    # specific event.
    #
    # @param id [String] ID of the event
    # @param version [Integer] version of event
    # @return [Hash]
    #
    def describe(id, version = nil)
      wf_event_id?(id)
      wf_version?(version) if version
      fragments = [id]
      fragments += ['history', version] if version
      api_get(fragments.uri_concat)
    end

    # PUT /api/v2/event/{id}
    # Update a specific event
    #
    # This method helps you update one or more properties of an event.
    #
    # @param id [String] a Wavefront Event ID
    # @param body [Hash] description of event.
    # @param modify [Bool] if this is true, then the existing event
    #   object will be fetched and merged with the user-supplied body.
    #   The resulting object will be passed to the API. If this is
    #   false, the body will be passed through unmodified.
    # @return [Hash]
    #
    def update(id, body, modify = true)
      wf_event_id?(id)
      raise ArgumentError unless body.is_a?(Hash)

      return api_put(id, body, 'application/json') unless modify

      api_put(id, hash_for_update(describe(id), body), 'application/json')
    end

    # POST /api/v2/event/{id}/close
    # Close a specific event.
    #
    # @param id [String] the ID of the event
    #
    def close(id)
      wf_event_id?(id)
      api_post([id, 'close'].uri_concat)
    end

    # GET /api/v2/event/{id}/tag
    # Get all tags associated with a specific event
    #
    # @param id [String] ID of the event
    # @returns [Hash] object describing the event with status and
    #   response keys
    #
    def tags(id)
      wf_event_id?(id)
      api_get([id, 'tag'].uri_concat)
    end

    # POST /api/v2/event/{id}/tag
    # Set all tags associated with a specific event.
    #
    # @param id [String] ID of the event
    # @param tags [Array] list of tags to set.
    # @returns [Hash] object describing the event with status and
    #   response keys
    #
    def tag_set(id, tags)
      wf_event_id?(id)
      tags = Array(tags)
      tags.each { |t| wf_string?(t) }
      api_post([id, 'tag'].uri_concat, tags, 'application/json')
    end

    # DELETE /api/v2/event/{id}/tag/{tagValue}
    # Remove a tag from a specific event.
    #
    # @param id [String] ID of the event
    # @param tag [String] tag to delete
    # @returns [Hash] object with 'status' key and empty 'repsonse'
    #
    def tag_delete(id, tag)
      wf_event_id?(id)
      wf_string?(tag)
      api_delete([id, 'tag', tag].uri_concat)
    end

    # PUT /api/v2/event/{id}/tag/{tagValue}
    # Add a tag to a specific event.
    #
    # @param id [String] ID of the event
    # @param tag [String] tag to set.
    # @returns [Hash] object with 'status' key and empty 'repsonse'
    #
    def tag_add(id, tag)
      wf_event_id?(id)
      wf_string?(tag)
      api_put([id, 'tag', tag].uri_concat)
    end
  end
end
