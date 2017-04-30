#!/usr/bin/env ruby

require_relative './spec_helper'

AGENT = 'fd248f53-378e-4fbe-bbd3-efabace8d724'.freeze

# Unit tests for agent class
#
class WavefrontAgentTest < WavefrontTestBase
  def test_list
    should_work(:list, 10, '?offset=10&limit=100')
  end

  def test_describe
    should_work(:describe, AGENT, AGENT)
    should_be_invalid(:describe)
    assert_raises(ArgumentError) { wf.describe }
  end

  def test_delete
    should_work(:delete, AGENT, AGENT, :delete)
    should_be_invalid('delete')
  end

  def test_rename
    should_work(:rename, [AGENT, 'newname'],
                [AGENT, { name: 'newname' }.to_json], :put,
                JSON_POST_HEADERS)
    assert_raises(ArgumentError) { wf.rename }
    assert_raises(ArgumentError) { wf.rename('abc123') }
    assert_raises(Wavefront::Exception::InvalidAgent) do
      wf.rename('abc', 'name')
    end
  end

  def test_undelete
    should_work(:undelete, AGENT, ["#{AGENT}/undelete", nil],
                :post, POST_HEADERS)
    should_be_invalid('undelete')
  end
end
