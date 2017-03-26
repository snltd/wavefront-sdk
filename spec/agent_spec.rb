#!/usr/bin/env ruby

require 'rest-client'
require 'minitest/autorun'
require 'spy/integration'
require_relative '../lib/wavefront-sdk/agent'

CREDS = {
  endpoint: 'test.example.com',
  token:    '0123456789-ABCDEF'
}.freeze

AGENT = 'fd248f53-378e-4fbe-bbd3-efabace8d724'.freeze

class WavefrontAgentTest < MiniTest::Test
  attr_reader :wf, :wf_noop, :uri_base, :headers

  def setup
    @wf = Wavefront::Agent.new(CREDS)
    @uri_base = "https://#{CREDS[:endpoint]}/api/v2/agent"
    @headers = { 'Authorization' => "Bearer #{CREDS[:token]}" }
  end

  def test_list
    msg = Spy.on(wf, :msg)
    rc = Spy.on(RestClient, :get)
    json = Spy.on(JSON, :parse)
    wf.list(10)
    assert rc.has_been_called_with?("#{uri_base}?offset=10&limit=100",
                                    headers)
    assert json.has_been_called?
    refute msg.has_been_called?
  end

  def test_describe
    msg = Spy.on(wf, :msg)
    rc = Spy.on(RestClient, :get)
    json = Spy.on(JSON, :parse)
    wf.describe(AGENT)
    assert rc.has_been_called_with?("#{uri_base}/#{AGENT}", headers)
    assert json.has_been_called?
    refute msg.has_been_called?

    assert_raises(ArgumentError) { wf.describe }
    assert_raises(Wavefront::Exception::InvalidAgent) { wf.describe('abc') }
  end

  def test_delete
    msg = Spy.on(wf, :msg)
    rc = Spy.on(RestClient, :delete)
    json = Spy.on(JSON, :parse)
    wf.delete(AGENT)
    assert rc.has_been_called_with?("#{uri_base}/#{AGENT}", headers)
    assert json.has_been_called?
    refute msg.has_been_called?
    assert_raises(Wavefront::Exception::InvalidAgent) { wf.delete('abc') }
  end

  def test_rename
    msg = Spy.on(wf, :msg)
    rc = Spy.on(RestClient, :put)
    json = Spy.on(JSON, :parse)
    wf.rename(AGENT, 'newname')
    h = headers.merge(:'Content-Type' => 'application/json',
                      :Accept         => 'application/json')
    assert rc.has_been_called_with?("#{uri_base}/#{AGENT}",
                                    '{"name":"newname"}', h)
    assert json.has_been_called?
    refute msg.has_been_called?

    assert_raises(ArgumentError) { wf.rename }
    assert_raises(ArgumentError) { wf.rename('abc123') }
    assert_raises(Wavefront::Exception::InvalidAgent) do
      wf.rename('abc', 'name')
    end
  end

  def test_undelete
    msg = Spy.on(wf, :msg)
    rc = Spy.on(RestClient, :post)
    json = Spy.on(JSON, :parse)
    wf.undelete(AGENT)
    h = headers.merge(:'Content-Type' => 'text/plain',
                      :Accept         => 'application/json')
    assert rc.has_been_called_with?("#{uri_base}/#{AGENT}/undelete", nil, h)
    assert json.has_been_called?
    refute msg.has_been_called?
    assert_raises(Wavefront::Exception::InvalidAgent) { wf.undelete('abc') }
  end
end
