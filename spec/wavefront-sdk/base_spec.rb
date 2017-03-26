#!/usr/bin/env ruby
#
require_relative './spec_helper'
require_relative '../../lib/wavefront-sdk/base'

class WavefrontBaseTest < MiniTest::Test
  attr_reader :wf, :wf_noop, :uri_base, :headers

  def setup
    @wf = Wavefront::Base.new(CREDS)
    @wf_noop = Wavefront::Base.new(CREDS, noop: true)
    @uri_base = "https://#{CREDS[:endpoint]}/api/v2/base"
    @headers = { 'Authorization' => "Bearer #{CREDS[:token]}" }
  end

  def test_parse_time
    assert_equal wf.parse_time(1469711187), 1469711187
    assert_equal wf.parse_time('2016-07-28 14:25:36 +0100'), 1469712336
    assert_equal wf.parse_time('2016-07-28'), 1469664000
    assert_instance_of Fixnum, wf.parse_time(Time.now)
    assert_raises(RuntimeError) { wf.parse_time('nonsense') }
  end

  def test_time_to_ms
    assert_equal wf.time_to_ms(1469711187), 1469711187000
    refute wf.time_to_ms('1469711187')
  end

  def test_to_qs
    assert_equal({ key1: 'val1', key2: 'value 2' }.to_qs,
                 'key1=val1&key2=value%202')
    assert_equal({}.to_qs, '')
    assert_equal({ key1: 'val1' }.to_qs, 'key1=val1')
  end

  def test_uri_concat
    assert_equal %w(a b).uri_concat, 'a/b'
    assert_equal ['', 'a', 'b'].uri_concat, '/a/b'
    assert_equal ['a', '/b'].uri_concat, 'a/b'
    assert_equal ['', 'a', 'b/'].uri_concat, '/a/b'
    assert_equal ['/a', '/b/', '/c'].uri_concat, '/a/b/c'
    assert_equal ['/a', '/b c'].uri_concat, '/a/b%20c'
  end

  def test_build_uri
    assert_instance_of URI::HTTPS, wf.build_uri('/api/test')
    assert_instance_of URI::HTTPS, wf.build_uri('/api/test', 'key1=val1')
    assert_equal wf.build_uri('test', 'k=v').to_s, "#{uri_base}/test?k=v"
    assert_equal wf.build_uri('test').to_s,
                 'https://test.example.com/api/v2/base/test'
  end

  def test_api_get
    msg = Spy.on(wf, :msg)
    rc = Spy.on(RestClient, :get)
    json = Spy.on(JSON, :parse)
    wf.api_get('/path', 'key1=val1')
    assert rc.has_been_called_with?("#{uri_base}/path?key1=val1", headers)
    assert json.has_been_called?
    refute msg.has_been_called?
  end

  def test_api_post
    msg = Spy.on(wf, :msg)
    rc = Spy.on(RestClient, :post)
    json = Spy.on(JSON, :parse)
    wf.api_post('/path', 'body')
    h = headers.merge(:'Content-Type' => 'text/plain',
                      :Accept         => 'application/json')
    assert rc.has_been_called_with?("#{uri_base}/path", 'body', h)
    assert json.has_been_called?
    refute msg.has_been_called?
  end

  def test_api_put
    msg = Spy.on(wf, :msg)
    rc = Spy.on(RestClient, :put)
    json = Spy.on(JSON, :parse)
    wf.api_put('/path', 'body')
    h = headers.merge(:'Content-Type' => 'application/json',
                      :Accept         => 'application/json')
    assert rc.has_been_called_with?("#{uri_base}/path", '"body"', h)
    assert json.has_been_called?
    refute msg.has_been_called?
  end

  def test_api_delete
    msg = Spy.on(wf, :msg)
    rc = Spy.on(RestClient, :delete)
    json = Spy.on(JSON, :parse)
    wf.api_delete('/path')
    assert rc.has_been_called_with?("#{uri_base}/path", headers)
    assert json.has_been_called?
    refute msg.has_been_called?
  end

  def test_api_noop
    %w(get post put delete).each do |call|
      msg = Spy.on(wf_noop, :msg)
      rc = Spy.on(RestClient, call.to_sym)
      json = Spy.on(JSON, :parse)
      wf_noop.send("api_#{call}", '/path')
      refute rc.has_been_called?
      refute json.has_been_called?
      count = call == 'put' ? 3 : 2
      assert_equal count, msg.calls.count
      msg.unhook
      json.unhook
    end
  end
end
