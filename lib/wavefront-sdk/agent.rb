require_relative './base'

module Wavefront
  class Agent < Wavefront::Base

    def list(offset = 0, limit = 100)
      call_get('', { offset: offset, limit: limit }.to_qs)
    end

    def describe(id)
      call_get(id)
    end

    def delete(id)
      call_delete(id)
    end

    def undelete(id)
      call_post([id, 'undelete'].uri_concat)
    end

    def update(id, payload)
      call_put(id, payload)
    end

    def rename(id, name)
      update(id, {name: name})
    end
  end
end
