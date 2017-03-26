require_relative './base'

module Wavefront
  class Agent < Wavefront::Base

    def list(offset = 0, limit = 100)
      api_get('', { offset: offset, limit: limit }.to_qs)
    end

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
