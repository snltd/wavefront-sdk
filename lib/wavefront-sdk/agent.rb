require_relative './base'

module Wavefront
  class Agent < Wavefront::Base

    # Returns a list of all agents in your account
    #
    # @param offset [Int] agent at which the list begins
    # @param limit [Int] the number of agents to return
    #
    def list(offset = 0, limit = 100)
      api_get('', { offset: offset, limit: limit }.to_qs)
    end

    # presents everything the server knows about the given agen
    #
    # @param id [String] ID of the agent
    # @return [Hash]
    def describe(id)
      wf_agent?(id)
      api_get(id)
    end

    def delete(id)
      wf_agent?(id)
      api_delete(id)
    end

    def undelete(id)
      wf_agent?(id)
      api_post([id, 'undelete'].uri_concat)
    end

    def update(id, payload)
      wf_agent?(id)
      api_put(id, payload)
    end

    def rename(id, name)
      wf_agent?(id)
      update(id, {name: name})
    end
  end
end
