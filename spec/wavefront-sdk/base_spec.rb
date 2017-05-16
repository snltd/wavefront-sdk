#!/usr/bin/env ruby

require_relative '../spec_helper'
require_relative '../../lib/wavefront-sdk/base'

#
# Test SDK base class
#
class WavefrontBaseTest < MiniTest::Test
  attr_reader :wf, :wf_noop, :uri_base, :headers

  def setup
    @wf = Wavefront::Base.new(CREDS)
    @wf_noop = Wavefront::Base.new(CREDS, noop: true)
    @uri_base = "#{CREDS[:endpoint]}/api/v2/base"
    @headers = { 'Authorization' => "Bearer #{CREDS[:token]}" }
    @update_keys = []
  end

  def test_time_to_ms
    now_ms = Time.now.to_i * 1000
    assert_equal wf.time_to_ms(now_ms), now_ms
    assert_equal wf.time_to_ms(1469711187), 1469711187000
    refute wf.time_to_ms([])
    refute wf.time_to_ms('1469711187')
  end

  def test_uri_concat
    assert_equal %w(a b).uri_concat, 'a/b'
    assert_equal ['', 'a', 'b'].uri_concat, '/a/b'
    assert_equal %w(a /b).uri_concat, 'a/b'
    assert_equal ['', 'a', 'b/'].uri_concat, '/a/b'
    assert_equal %w(/a /b/ /c).uri_concat, '/a/b/c'
    assert_equal ['/a', '/b c'].uri_concat, '/a/b c'
  end

  def test_api_get
    uri = "#{uri_base}/path?key1=val1"
    stub_request(:get, uri).to_return(body: {}.to_json, status: 200)
    wf.api_get('/path', key1: 'val1')
    assert_requested(:get, uri, headers: headers)
  end

  def test_api_post
    uri = "#{uri_base}/path"
    obj = {key: 'value'}
    stub_request(:post, uri).to_return(body: {}.to_json, status: 200)
    wf.api_post('/path', 'string')
    assert_requested(:post, uri, body: 'string',
                                 headers: headers.merge(POST_HEADERS))
    wf.api_post('/path', obj)
    assert_requested(:post, uri, body: obj.to_json,
                                 headers: headers.merge(POST_HEADERS))
  end

  def test_api_put
    uri = "#{uri_base}/path"
    stub_request(:put, uri).to_return(body: {}.to_json, status: 200)
    wf.api_put('/path', 'body')
    assert_requested(:put, uri, body: 'body'.to_json,
                                headers: headers.merge(JSON_POST_HEADERS))
  end

  def test_api_delete
    uri = "#{uri_base}/path"
    stub_request(:delete, uri).to_return(body: {}.to_json, status: 200)
    wf.api_delete('/path')
    assert_requested(:delete, uri, headers: headers)
  end

  def test_api_noop
    uri = "#{uri_base}/path"

    %w(get post put delete).each do |call|
      stub_request(call.to_sym, uri)
      wf_noop.send("api_#{call}", '/path')
      refute_requested(call.to_sym, uri)
    end
  end

  def test_hash_for_update
    wf.instance_variable_set('@update_keys',  [:k1, :k2])
    body = { k1: 'ov1', k2: 'ov2', k3: 'ov3'}
    upd = { k2: 'nv1' }

    assert_equal(wf.hash_for_update(body, upd), { k1: 'ov1', k2: 'nv1'})
  end
end
