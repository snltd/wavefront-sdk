require_relative './base'

module Wavefront
  class Agent < Wavefront::Base

    def list(offset = 0, limit = 100)
      api_get('', { offset: offset, limit: limit }.to_qs)
    end

    def describe(id)
      api_get(id)
    end

    def delete(id)
      api_delete(id)
    end

    def undelete(id)
      api_post([id, 'undelete'].uri_concat)
    end

    def update(id, payload)
      api_put(id, payload)
    end

    def rename(id, name)
      update(id, {name: name})
    end
  end
end
