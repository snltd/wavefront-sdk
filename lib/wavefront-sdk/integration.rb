require_relative './base'

module Wavefront
  #
  # Manage and query Wavefront integrations.
  #
  class Integration < Base

    # GET /api/v2/integration
    # Gets a flat list of all Wavefront integrations available,
    # along with their status
    #
    # @param offset [Int] proxy at which the list begins
    # @param limit [Int] the number of proxies to return
    #
    def list(offset = 0, limit = 100)
      api_get('', { offset: offset, limit: limit })
    end

    # GET /api/v2/integration/id
    # Gets a single Wavefront integration by its id, along with its
    # status
    #
    # @param id [String] ID of the proxy
    # @return [Wavefront::Response]
    #
    def describe(id)
      wf_integration_id?(id)
      api_get(id)
    end

    # POST /api/v2/integration/id/install
    # Installs a Wavefront integration
    #
    # @param id [String] ID of the integration
    # @return [Wavefront::Response]
    #
    def install(id)
      wf_integration_id?(id)
      api_post([id, 'install'].uri_concat, nil)
    end

    # POST /api/v2/integration/id/uninstall
    # Uninstalls a Wavefront integration
    #
    # @param id [String] ID of the integration
    # @return [Wavefront::Response]
    #
    def uninstall(id)
      wf_integration_id?(id)
      api_post([id, 'uninstall'].uri_concat, nil)
    end

    # GET /api/v2/integration/id/status
    # Gets the status of a single Wavefront integration
    #
    # @param id [String] ID of the integration
    # @return [Wavefront::Response]
    #
    def status(id)
      wf_integration_id?(id)
      api_get([id, 'status'].uri_concat)
    end

    # GET /api/v2/integration/status
    # Gets the status of all Wavefront integrations
    #
    # @return [Wavefront::Response]
    #
    def statuses
      api_get('status')
    end

    # GET /api/v2/integration/manifests
    # Gets all Wavefront integrations as structured in their
    # integration manifests, along with their status
    #
    def manifests
      api_get('manifests')
    end
  end
end
