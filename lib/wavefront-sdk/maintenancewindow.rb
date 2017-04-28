require_relative './base'

module Wavefront
  #
  # Manage and query Wavefront external links.
  #
  class MaintenanceWindow < Wavefront::Base

    # Get all maintenance windows for a customer.
    #
    # @param offset [Integer] link at which the list begins
    # @param limit [Integer] the number of link to return
    #
    def list(offset = 0, limit = 100)
      api_get('', { offset: offset, limit: limit }.to_qs)
    end

    # Create a maintenance window.
    #
    # @param body [Hash] a hash of parameters describing the window.
    # @return [Hash]
    # @raise any validation errors from body
    #
    def create(body)
      raise ArgumentError unless body.is_a?(Hash)

      desc = { reason:   [:wf_string?, :required],
               title:    [:wf_string?, :required],
               start:    [:wf_epoch?, :required],
               end:      [:wf_epoch?, :required],
               tags:     [:wf_tag?, :optional],
               hostTags: [:wf_tag?, :optional] }

      body[:start] = parse_time(body[:start]) if body[:start]
      body[:end] = parse_time(body[:end]) if body[:end]

      validate_hash(body, desc)

      api_post('', body.to_json, 'application/json')
    end

    # Get a specific maintenance window.
    #
    # @param id [String, Integer] ID of the maintenance window
    # @return [Hash]
    #
    def describe(id)
      wf_maintenance_window?(id)
      api_get(id)
    end

    # Delete a specific maintenance window.
    #
    # @param id [String, Integer] ID of the maintenance window
    # @return [Hash]
    #
    def delete(id)
      wf_maintenance_window?(id)
      api_delete(id)
    end

    # Update a specific maintenance window.
    #
    # @param body [Hash] a hash of parameters describing the window.
    # @return [Hash]
    # @raise any validation errors from body
    #
    def update(id, body)
      raise ArgumentError unless body.is_a?(Hash)

      desc = { reason:   [:wf_string?, :optional],
               title:    [:wf_string?, :optional],
               start:    [:wf_epoch?, :optional],
               end:      [:wf_epoch?, :optional],
               tags:     [:wf_tag?, :optional],
               hostTags: [:wf_tag?, :optional] }

      body[:start] = parse_time(body[:start]) if body[:start]
      body[:end] = parse_time(body[:end]) if body[:end]

      validate_hash(body, desc)

      api_put(id, payload)
    end
  end
end
