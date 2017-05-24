#!/usr/bin/env ruby

require_relative '../spec_helper'

MESSAGE = 'message_id'.freeze # don't know what these look like yet

# Unit tests for Message class
#
class WavefrontMessageTest < WavefrontTestBase
  def test_list
    should_work(:list, 10, '?offset=10&limit=100&unreadOnly=true')
    should_work(:list, [12, 34, false], '?offset=12&limit=34&unreadOnly=false')
  end

  def test_read
    should_work(:read, MESSAGE, "#{MESSAGE}/read", :post, POST_HEADERS)
    should_be_invalid(:read, 'bad id')
  end
end
