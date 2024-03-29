# frozen_string_literal: true

require_relative 'core/api'

module Wavefront
  #
  # Manage and query Wavefront proxies.
  #
  class Proxy < CoreApi
    # GET /api/v2/proxy
    # Get all proxies for a customer
    #
    # @param offset [Int] proxy at which the list begins
    # @param limit [Int] the number of proxies to return
    #
    def list(offset = 0, limit = 100)
      api.get('', offset: offset, limit: limit)
    end

    # DELETE /api/v2/proxy/{id}
    # Delete a specific proxy
    #
    # Deleting an active proxy moves it to 'trash', from where it
    # can be restored with an #undelete operation. Deleting a proxy
    # in 'trash' removes it for ever.
    #
    # @param id [String] ID of the proxy
    # @return [Wavefront::Response]
    #
    def delete(id)
      wf_proxy_id?(id)
      api.delete(id)
    end

    # GET /api/v2/proxy/{id}
    # Get a specific proxy
    #
    # @param id [String] ID of the proxy
    # @return [Wavefront::Response]
    #
    def describe(id)
      wf_proxy_id?(id)
      api.get(id)
    end

    # POST /api/v2/proxy/{id}/undelete
    # Undelete a specific proxy
    #
    # Move a proxy from 'trash' back into active service.
    #
    # @param id [String] ID of the proxy
    # @return [Wavefront::Response]
    #
    def undelete(id)
      wf_proxy_id?(id)
      api.post([id, 'undelete'].uri_concat)
    end

    # PUT /api/v2/proxy/{id}
    # Update the name of a specific proxy
    #
    # Rename a proxy. This changes the human-readable name, not the
    # unique identifier.
    #
    # @param id [String] ID of the proxy
    # @param name [String] new name
    # @return [Wavefront::Response]
    #
    def rename(id, name)
      wf_proxy_id?(id)
      wf_string?(name)
      update(id, name: name)
    end

    # A generic function to change properties of a proxy. So far as I
    # know, only the 'name' property can currently be changed, and we
    # supply a dedicated #rename method for that.
    #
    # @param id [String] ID of the proxy
    # @param payload [Hash] a key: value hash, where the key is the
    #   property to change and the value is its desired value. No
    #   validation is performed on any part of the payload.
    # @return [Wavefront::Response]
    #
    def update(id, payload)
      wf_proxy_id?(id)
      api.put(id, payload)
    end

    # Shutdown a proxy. Requires proxy >=5.x. Might not be effective if you
    # have something like systemd or SMF restarting a failed proxy.
    # @param id [String] ID of the proxy
    # @return [Wavefront::Response]
    #
    def shutdown(id)
      wf_proxy_id?(id)
      api.put(id, { shutdown: true }, 'application/json')
    end

    # GET /api/v2/proxy/{id}/config
    # Get a specific proxy config
    #
    # @param id [String] ID of the proxy
    # @return [Wavefront::Response]
    #
    def config(id)
      wf_proxy_id?(id)
      api.get([id, 'config'].uri_concat)
    end

    # GET /api/v2/proxy/{id}/preprocessorRules
    # Get a specific proxy preprocessor rules
    #
    # @param id [String] ID of the proxy
    # @return [Wavefront::Response]
    #
    def preprocessor_rules(id)
      wf_proxy_id?(id)
      api.get([id, 'preprocessorRules'].uri_concat)
    end
  end
end
