require_relative './base'

module Wavefront
  #
  # View and manage dashboards.
  #
  class Dashboard < Wavefront::Base

    # Get all dashboards for a customer.
    #
    # @param offset [Int] dashboard at which the list begins
    # @param limit [Int] the number of dashboard to return
    # @return [Hash]
    #
    def list(offset = 0, limit = 100)
      api_get('', { offset: offset, limit: limit }.to_qs)
    end

    # Create a specific dashboard.
    # Refer to the Swagger API docs for valid keys.
    #
    # @param body [Hash] description of dashboard
    # @return [Hash]
    #
    def create(body)
      api_post('', body.to_json, 'application/json')
    end

    # Delete a specific dashboard.
    # Deleting an active dashboard moves it to 'trash', from where it can
    # be restored with an #undelete operation. Deleting an dashboard in
    # 'trash' removes it for ever.
    #
    # @param id [String] ID of the dashboard
    # @return [Hash]
    #
    def delete(id)
      wf_dashboard?(id)
      api_delete(id)
    end

    # Get a specific dashboard / Get a specific historical version of a
    # specific dashboard.
    #
    # @param id [String] ID of the dashboard
    # @param version [Integer] version of dashboard
    # @return [Hash]
    #
    def describe(id, version = nil)
      wf_dashboard?(id)
      wf_version?(version) if version
      fragments = [id]
      fragments += ['history', version] if version
      api_get(fragments.uri_concat)
    end

    def update(id, body)
      wf_dashboard?(id)
      api_put(id, body)
    end

    # Get the version history of an dashboard
    #
    # @param id [String] ID of the dashboard
    # @return [Hash]
    #
    def history(id)
      wf_dashboard?(id)
      api_get([id, 'history'].uri_concat)
    end

    # Snooze a specific dashboard for some number of seconds.
    #
    # @param id [String] ID of the dashboard
    # @param time [Integer] how many seconds to snooze for
    # @returns [Hash] object describing the dashboard with status and
    #   response keys
    #
    def snooze(id, time = 3600)
      wf_dashboard?(id)
      api_post([id, 'snooze'].uri_concat, time)
    end

    # Get all tags associated with a specific dashboard
    #
    # @param id [String] ID of the dashboard
    # @returns [Hash] object describing the dashboard with status and
    #   response keys
    #
    def tags(id)
      wf_dashboard?(id)
      api_get([id, 'tag'].uri_concat)
    end

    # Set all tags associated with a specific dashboard.
    #
    # @param id [String] ID of the dashboard
    # @param tags [Array] list of tags to set.
    # @returns [Hash] object describing the dashboard with status and
    #   response keys
    #
    def tag_set(id, tags)
      wf_dashboard?(id)
      tags = Array(tags)
      tags.each { |t| wf_string?(t) }
      api_post([id, 'tag'].uri_concat, tags.to_json, 'application/json')
    end

    # Add a tag to a specific dashboard.
    #
    # @param id [String] ID of the dashboard
    # @param tag [String] tag to set.
    # @returns [Hash] object with 'status' key and empty 'repsonse'
    #
    def tag_add(id, tag)
      wf_dashboard?(id)
      wf_string?(tag)
      api_put([id, 'tag', tag].uri_concat)
    end

    # Remove a tag from a specific dashboard.
    #
    # @param id [String] ID of the dashboard
    # @param tag [String] tag to delete
    # @returns [Hash] object with 'status' key and empty 'repsonse'
    #
    def tag_delete(id, tag)
      wf_dashboard?(id)
      wf_string?(tag)
      api_delete([id, 'tag', tag].uri_concat)
    end

    # Move an dashboard from 'trash' back into active service.
    #
    # @param id [String] ID of the dashboard
    # @return [Hash]
    #
    def undelete(id)
      wf_dashboard?(id)
      api_post([id, 'undelete'].uri_concat)
    end

    # Unsnooze an dashboard
    #
    # @param id [String] ID of the dashboard
    # @returns [Hash] object describing the dashboard with status and
    #   response keys
    #
    def unsnooze(id)
      wf_dashboard?(id)
      api_post([id, 'unsnooze'].uri_concat)
    end

    # Get a count of dashboards in all possible states
    #
    # @return [Hash]
    #
    def summary
      api_get('summary')
    end
  end
end
