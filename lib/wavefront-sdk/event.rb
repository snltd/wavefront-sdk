# frozen_string_literal: true

require_relative 'core/api'
require_relative 'api_mixins/tag'

module Wavefront
  #
  # View and manage events. Events are identified by their millisecond
  # epoch timestamp.
  #
  class Event < CoreApi
    include Wavefront::Mixin::Tag

    def update_keys
      %i[id name]
    end

    # GET /api/v2/event
    # List all the events for a customer within a time range.
    #
    # @param from [Time, Integer] start of time range. The API
    #   requires this time as epoch milliseconds, but we will also
    #   accept it as a Ruby Time object.
    # @param to [Time, Integer] end ot time range. Can be epoch
    #   millisecods or a Ruby time. If not supplied, defaults to the
    #   current time.
    # @param cursor [String] event from which to start listing
    # @param limit [Integer] the number of events to return
    # @return [Wavefront::Response]
    #
    # rubocop:disable Metrics/ParameterLists
    def list(from = nil, to = Time.now, limit = 100, cursor = nil)
      raise ArgumentError unless from && to

      body = list_body(from, to, limit, cursor)
      wf_event_id?(cursor) if cursor
      wf_ms_ts?(body[:earliestStartTimeEpochMillis])
      wf_ms_ts?(body[:latestStartTimeEpochMillis])
      api.get('', body.cleanse)
    end
    # rubocop:enable Metrics/ParameterLists

    # POST /api/v2/event
    # Create a specific event.
    #
    # We used to validate keys and provide helpers for time fields.
    # Now ensuring a valid hash is entirely left up to the user.
    # Refer to the Swagger docs for more information.
    #
    # @param body [Hash] description of event
    # @return [Wavefront::Response]
    #
    def create(body)
      raise ArgumentError unless body.is_a?(Hash)

      api.post('', body, 'application/json')
    end

    # DELETE /api/v2/event/id
    # Delete a specific event.
    #
    # @param id [String] ID of the alert
    # @return [Wavefront::Response]
    #
    def delete(id)
      wf_event_id?(id)
      api.delete(id)
    end

    # GET /api/v2/event/id
    # Get a specific event / Get a specific historical version of a
    # specific event.
    #
    # @param id [String] ID of the event
    # @param version [Integer] version of event
    # @return [Wavefront::Response]
    #
    def describe(id, version = nil)
      wf_event_id?(id)
      wf_version?(version) if version
      fragments = [id]
      fragments += ['history', version] if version
      api.get(fragments.uri_concat)
    end

    # PUT /api/v2/event/id
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
    # @return [Wavefront::Response]
    #
    def update(id, body, modify = true)
      wf_event_id?(id)
      raise ArgumentError unless body.is_a?(Hash)

      return api.put(id, body, 'application/json') unless modify

      api.put(id,
              hash_for_update(describe(id).response, body),
              'application/json')
    end

    # POST /api/v2/event/id/close
    # Close a specific event.
    #
    # @param id [String] the ID of the event
    #
    def close(id)
      wf_event_id?(id)
      api.post([id, 'close'].uri_concat)
    end

    # GET /api/v2/event/{id}/alertFiringDetails
    # Return details of a particular alert firing, including all the series
    # that fired during the referred alert firing
    #
    # @param id [String] ID of the event
    # @return [Wavefront::Response]
    #
    def alert_firing_details(id)
      wf_event_id?(id)
      api.get([id, 'alertFiringDetails'].uri_concat)
    end

    # GET /api/v2/event/{id}/alertQueriesSlug
    # If the specified event is associated with an alert, returns a slug
    # encoding the queries having to do with that alert firing or resolution
    # @param id [String] ID of the event
    # @return [Wavefront::Response]
    #
    def alert_queries_slug(id)
      wf_event_id?(id)
      api.get([id, 'alertQueriesSlug'].uri_concat)
    end

    # GET /api/v2/event/{id}/events
    # List all related events for a specific firing event with a time span of
    # one hour
    # @param id [String] ID of the event
    # @param opts [Hash] containing one or more of
    #   is_overlapped [Bool]
    #   rendering_method [Symbol,String] one of :HOST, :METRIC, :SIMILARITY
    #   limit [Integer]
    # @return [Wavefront::Response]
    #
    def events(id, opts = {})
      wf_event_id?(id)

      api.get([id, 'events'].uri_concat,
              { isOverlapped: opts[:is_overlapped] || false,
                renderingMethod: (opts[:rendering_method] || :HOST).to_s,
                limit: opts[:limit] || nil }.compact)
    end

    # GET /api/v2/event/alertFirings
    # Get firings events of an alert within a time range
    # @param alert_id [String] ID of the alert
    # @param opts [Hash] containing one or more of
    #   earliest_start [Integer] epoch ms timestamp
    #   latest_start [Integer] epoch ms timestamp
    #   ascending [Bool]
    #   limit [Integer]
    # @return [Wavefront::Response]
    #
    def alert_firings(alert_id, opts = {})
      wf_alert_id?(alert_id)

      api.get('alertFirings',
              { alertId: alert_id,
                earliestStartTimeEpochMillis: opts[:earliest_start] || nil,
                latestStartTimeEpochMillis: opts[:latest_start] || nil,
                limit: opts[:limit] || nil,
                asc: opts[:asc] || true }.compact)
    end

    private

    def valid_id?(id)
      wf_event_id?(id)
    end

    def list_body(t_start, t_end, limit, cursor)
      { earliestStartTimeEpochMillis: parse_time(t_start, true),
        latestStartTimeEpochMillis: parse_time(t_end, true),
        cursor: cursor,
        limit: limit }
    end
  end
end
