#!/usr/bin/env ruby
# frozen_string_literal: true

require_relative '../spec_helper'

MESSAGE = 'CLUSTER::IHjNaHM9'

# Unit tests for Message class
#
class WavefrontMessageTest < WavefrontTestBase
  def test_list
    assert_gets('/api/v2/message?offset=10&limit=100&unreadOnly=true') do
      wf.list(10)
    end

    assert_gets('/api/v2/message?offset=12&limit=34&unreadOnly=false') do
      wf.list(12, 34, false)
    end
  end

  def test_read
    assert_posts("/api/v2/message/#{id}/read") { wf.read(id) }
    assert_invalid_id { wf.read(invalid_id) }
  end

  private

  def id
    'CLUSTER::IHjNaHM9'
  end

  def invalid_id
    '__!!__'
  end
end
