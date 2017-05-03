require_relative './base'

module Wavefront
  #
  # Manage and query Wavefront agents.
  #
  class Agent < Wavefront::Base

    # GET /api/v2/agent
    # Get all agents for a customer
    #
    # @param offset [Int] agent at which the list begins
    # @param limit [Int] the number of agents to return
    #
    def list(offset = 0, limit = 100)
      api_get('', { offset: offset, limit: limit })
    end

    # DELETE /api/v2/agent/{id}
    # Delete a specific agent
    #
    # Deleting an active agent moves it to 'trash', from where it
    # can be restored with an #undelete operation. Deleting an agent
    # in 'trash' removes it for ever.
    #
    # @param id [String] ID of the agent
    # @return [Hash]
    #
    def delete(id)
      wf_agent_id?(id)
      api_delete(id)
    end

    # GET /api/v2/agent/{id}
    # Get a specific agent
    #
    # @param id [String] ID of the agent
    # @return [Hash]
    #
    def describe(id)
      wf_agent_id?(id)
      api_get(id)
    end

    # POST /api/v2/agent/{id}/undelete
    # Undelete a specific agent
    #
    # Move an agent from 'trash' back into active service.
    #
    # @param id [String] ID of the agent
    # @return [Hash]
    #
    def undelete(id)
      wf_agent_id?(id)
      api_post([id, 'undelete'].uri_concat)
    end

    # PUT /api/v2/agent/{id}
    # Update the name of a specific agent
    #
    # Rename an agent. This changes the human-readable name, not the
    # unique identifier.
    #
    # @param id [String] ID of the agent
    # @param name [String] new name
    # @return [Hash]
    #
    def rename(id, name)
      wf_agent_id?(id)
      wf_string?(name)
      update(id, {name: name})
    end

    # A generic function to change properties of an agent. So far as I
    # know, only the 'name' property can currently be changed, and we
    # supply a dedicated #rename method for that.
    #
    # @param id [String] ID of the agent
    # @param payload [Hash] a key: value hash, where the key is the
    #   property to change and the value is its desired value. No
    #   validation is performed on any part of the payload.
    # @return [Hash]
    #
    def update(id, payload)
      wf_agent_id?(id)
      api_put(id, payload)
    end
  end
end
