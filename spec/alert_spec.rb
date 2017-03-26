#!/usr/bin/env ruby

require 'rest-client'
require 'minitest/autorun'
require 'spy/integration'
require_relative '../lib/wavefront-sdk/alert'

CREDS = {
  endpoint: 'test.example.com',
  token:    '0123456789-ABCDEF'
}.freeze

class WavefrontAgentTest < MiniTest::Test
  attr_reader :wf, :wf_noop, :uri_base, :headers

  def setup
    @wf = Wavefront::Alert.new(CREDS)
    @uri_base = "https://#{CREDS[:endpoint]}/api/v2/alert"
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
    wf.describe('abc123')
    assert rc.has_been_called_with?("#{uri_base}/abc123", headers)
    assert json.has_been_called?
    refute msg.has_been_called?

    assert_raises(ArgumentError) { wf.describe }
  end

  def test_delete
    msg = Spy.on(wf, :msg)
    rc = Spy.on(RestClient, :delete)
    json = Spy.on(JSON, :parse)
    wf.delete('abc123')
    assert rc.has_been_called_with?("#{uri_base}/abc123", headers)
    assert json.has_been_called?
    refute msg.has_been_called?
  end

  def test_undelete
    msg = Spy.on(wf, :msg)
    rc = Spy.on(RestClient, :post)
    json = Spy.on(JSON, :parse)
    wf.undelete('abc123')
    h = headers.merge(:'Content-Type' => 'text/plain',
                      :Accept         => 'application/json')
    assert rc.has_been_called_with?("#{uri_base}/abc123/undelete", nil, h)
    assert json.has_been_called?
    refute msg.has_been_called?
  end
end
