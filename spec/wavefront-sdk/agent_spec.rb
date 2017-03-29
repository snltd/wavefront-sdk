#!/usr/bin/env ruby

require_relative './spec_helper'
require_relative '../../lib/wavefront-sdk/agent'

#
# Unit tests for agent class
#
class WavefrontAgentTest < MiniTest::Test
  attr_reader :wf, :wf_noop, :uri_base, :headers

  def setup
    @wf = Wavefront::Agent.new(CREDS)
    @uri_base = "https://#{CREDS[:endpoint]}/api/v2/agent"
    @headers = { 'Authorization' => "Bearer #{CREDS[:token]}" }
  end

  def test_list
    should_work('list', 10, '?offset=10&limit=100')
  end

  def test_describe
    should_work('describe', AGENT, AGENT)
    assert_raises(ArgumentError) { wf.describe }
    assert_raises(Wavefront::Exception::InvalidAgent) { wf.describe('abc') }
  end

  def test_delete
    should_work('delete', AGENT, AGENT, :delete)
    assert_raises(Wavefront::Exception::InvalidAgent) { wf.delete('abc') }
  end

  def test_rename
    should_work('rename', [AGENT, 'newname'],
                [AGENT, { name: 'newname' }.to_json], :put,
                JSON_POST_HEADERS)
    assert_raises(ArgumentError) { wf.rename }
    assert_raises(ArgumentError) { wf.rename('abc123') }
    assert_raises(Wavefront::Exception::InvalidAgent) do
      wf.rename('abc', 'name')
    end
  end

  def test_undelete
    should_work('undelete', AGENT, ["#{AGENT}/undelete", nil],
                :post, POST_HEADERS)

    assert_raises(Wavefront::Exception::InvalidAgent) { wf.undelete('abc') }
  end
end
