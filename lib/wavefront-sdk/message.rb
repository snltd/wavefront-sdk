require_relative 'core/api'

module Wavefront
  #
  # Manage and query Wavefront messages.
  #
  class Message < CoreApi
    # GET /api/v2/message
    # Gets messages applicable to the current user, i.e. within time
    # range and distribution scope
    #
    # @param offset [Int] agent at which the list begins
    # @param limit [Int] the number of agents to return
    #
    def list(offset = 0, limit = 100, unread_only = true)
      api.get('', offset: offset, limit: limit, unreadOnly: unread_only)
    end

    # POST /api/v2/message/id/read
    # Mark a specific message as read
    #
    # @param id [String] message ID to mark as read
    #
    def read(id)
      wf_message_id?(id)
      api.post([id, 'read'].uri_concat)
    end
  end
end
