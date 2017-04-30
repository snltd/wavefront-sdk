require_relative './base'

module Wavefront
  #
  # Manage and query Wavefront messages.
  #
  class Message < Wavefront::Base

    # GET /api/v2/message
    # Gets messages applicable to the current user, i.e. within time
    # range and distribution scope
    #
    # @param offset [Int] agent at which the list begins
    # @param limit [Int] the number of agents to return
    #
    def list(offset = 0, limit = 100)
      api_get('', { offset: offset, limit: limit }.to_qs)
    end

    # POST /api/v2/message/{id}/read
    # Mark a specific message as read
    #
    # @param [id] message ID to mark as read
    #
    def read(id)
      wf_message?(id)
      api_post([id, 'read'].uri_concat)
    end
  end
end
