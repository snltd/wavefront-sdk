# frozen_string_literal: true

require_relative 'core/api'
require_relative 'api_mixins/tag'

module Wavefront
  #
  # Manage and query Wavefront monitored clusters
  #
  class MonitoredCluster < CoreApi
    include Wavefront::Mixin::Tag

    def update_keys
      %i[id]
    end

    # GET /api/v2/monitoredcluster
    # Get all monitored clusters
    # @param offset [Integer] cluster at which the list begins
    # @param limit [Integer] the number of clusters to return
    # @return [Wavefront::Response]
    #
    def list(offset = 0, limit = 100)
      api.get('', offset: offset, limit: limit)
    end

    # POST /api/v2/monitoredcluster
    # Create a specific cluster
    # @param body [Hash] a hash of parameters describing the cluster.
    #   Please refer to the Wavefront Swagger docs for key:value
    #   information
    # @return [Wavefront::Response]
    #
    def create(body)
      raise ArgumentError unless body.is_a?(Hash)

      api.post('', body, 'application/json')
    end

    # DELETE /api/v2/monitoredcluster/{id}
    # Delete a specific cluster
    # @param id [String, Integer] ID of the maintenance cluster
    # @return [Wavefront::Response]
    #
    def delete(id)
      wf_monitoredcluster_id?(id)
      api.delete(id)
    end

    # GET /api/v2/monitoredcluster/{id}
    # Get a specific cluster
    # @param id [String, Integer] ID of the cluster
    # @return [Wavefront::Response]
    #
    def describe(id)
      wf_monitoredcluster_id?(id)
      api.get(id)
    end

    # PUT /api/v2/monitoredcluster/{id}
    # Update a specific cluster
    # @return [Wavefront::Response]
    #
    def update(id, body, modify = true)
      wf_monitoredcluster_id?(id)
      raise ArgumentError unless body.is_a?(Hash)

      return api.put(id, body, 'application/json') unless modify

      api.put(id, hash_for_update(describe(id).response, body),
              'application/json')
    end

    # PUT /api/v2/monitoredcluster/merge/{id1}/{id2}
    # Merge two monitored clusters. The first cluster will remain and the
    # second cluster will be deleted, with its id added as an alias to the
    # first cluster.
    # @param id1 [String, Integer] ID of the target cluster
    # @param id2 [String, Integer] ID of the other cluster
    # @return [Wavefront::Response]
    #
    def merge(id1, id2)
      wf_monitoredcluster_id?(id1)
      wf_monitoredcluster_id?(id2)

      api.put(['merge', id1, id2].uri_concat, nil, 'application/json')
    end

    def valid_id?(id)
      wf_monitoredcluster_id?(id)
    end
  end
end
