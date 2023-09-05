# frozen_string_literal: true

require_relative 'defs/constants'
require_relative 'core/api'

module Wavefront
  #
  # View and manage the Wavefront span sampling policy.
  #
  class SpanSamplingPolicy < CoreApi
    def update_keys
      %i[name active expression description samplingPercent]
    end

    # GET /api/v2/spansamplingpolicy
    # Get all sampling policies for a customer
    #
    # @param offset [Int] policy at which the list begins
    # @param limit [Int] the number of policies to return
    # @return [Wavefront::Response]
    #
    def list(offset = 0, limit = 100)
      api.get('', offset: offset, limit: limit)
    end

    # POST /api/v2/spansamplingpolicy
    # Create a span sampling policy
    #
    # @param body [Hash] description of policy
    # @return [Wavefront::Response]
    #
    def create(body)
      raise ArgumentError unless body.is_a?(Hash)

      api.post('', body, 'application/json')
    end

    # DELETE /api/v2/spansamplingpolicy/{id}
    # Delete a specific span sampling policy
    #
    # Deleting an active policy moves it to 'trash', from where it can
    # be restored with an #undelete operation. Deleting an policy in
    # 'trash' removes it for ever.
    #
    # @param id [String] ID of the policy
    # @return [Wavefront::Response]
    #
    def delete(id)
      wf_spansamplingpolicy_id?(id)
      api.delete(id)
    end

    # GET /api/v2/spansamplingpolicy/deleted
    # Get all deleted sampling policies for a customer
    # @return [Wavefront::Response]
    #
    def deleted
      api.get('deleted')
    end

    # GET /api/v2/spansamplingpolicy/{id}
    # GET /api/v2/spansamplingpolicy/{id}/history/{version}
    # Get a specific span sampling policy
    # Get a specific policy / Get a specific historical version of a specific
    # sampling policy
    #
    # @param id [String] ID of the policy
    # @param version [Integer] version of policy
    # @return [Wavefront::Response]
    #
    def describe(id, version = nil)
      wf_spansamplingpolicy_id?(id)
      wf_version?(version) if version
      fragments = [id]
      fragments += ['history', version] if version
      api.get(fragments.uri_concat)
    end

    # PUT /api/v2/spansamplingpolicy/{id}
    # Update a specific span sampling policy
    #
    # @param id [String] a Wavefront span-sampling policy ID
    # @param body [Hash] key-value hash of the parameters you wish
    #   to change
    # @param modify [true, false] if true, use {#describe()} to get
    #   a hash describing the existing object, and modify that with
    #   the new body. If false, pass the new body straight through.
    # @return [Wavefront::Response]

    def update(id, body, modify = true)
      wf_spansamplingpolicy_id?(id)
      raise ArgumentError unless body.is_a?(Hash)

      return api.put(id, body, 'application/json') unless modify

      api.put(id, hash_for_update(describe(id).response, body),
              'application/json')
    end

    # GET /api/v2/spansamplingpolicy/{id}/history
    # Get the version history of a specific sampling policy
    #
    # @param id [String] ID of the policy
    # @return [Wavefront::Response]
    #
    def history(id, offset = nil, limit = nil)
      wf_spansamplingpolicy_id?(id)
      qs = {}
      qs[:offset] = offset if offset
      qs[:limit] = limit if limit

      api.get([id, 'history'].uri_concat, qs)
    end

    # POST /api/v2/spansamplingpolicy/{id}/undelete
    # Restore a deleted span sampling policy
    #
    # @param id [String] ID of the policy
    # @return [Wavefront::Response]
    #
    def undelete(id)
      wf_spansamplingpolicy_id?(id)
      api.post([id, 'undelete'].uri_concat)
    end
  end
end
