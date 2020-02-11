#!/usr/bin/env ruby
# frozen_string_literal: true

require_relative '../../spec_helper'
require_relative '../../../lib/wavefront-sdk/core/api_caller'

# Wavefront::ApiCaller needs a class which responds to #api_base as
# its first argument
#
class Dummy
  def api_base
    '/base'
  end

  def api_path
    ['', 'api', 'v2', api_base].uri_concat
  end
end

# Test Wavefront API caller
#
class WavefrontApiCallerTest < MiniTest::Test
  attr_reader :wf, :wf_noop, :uri_base, :headers

  def setup
    @wf = Wavefront::ApiCaller.new(Dummy.new, CREDS)
    @wf_noop = Wavefront::ApiCaller.new(Dummy.new, CREDS, noop: true)
    @uri_base = "https://#{CREDS[:endpoint]}/api/v2/base"
    @headers = { 'Authorization' => "Bearer #{CREDS[:token]}" }
    @update_keys = []
  end

  def test_get
    uri = "#{uri_base}/path?key1=val1"
    stub_request(:get, uri).to_return(body: DUMMY_RESPONSE, status: 200)
    wf.get('/path', key1: 'val1')
    assert_requested(:get, uri, headers: headers)
  end

  def test_get_flat_params
    query = { rkey: %w[val1 val2 val3], ukey: 36 }
    uri = "#{uri_base}/path?rkey=val1&rkey=val2&rkey=val3&ukey=36"
    stub_request(:get, uri).to_return(body: DUMMY_RESPONSE, status: 200)
    wf.get_flat_params('/path', query)
    assert_requested(:get, uri, headers: headers)
  end

  def test_get_stream
    uri = "#{uri_base}/path?key1=val1"
    stub_request(:get, uri).to_return(body: DUMMY_RESPONSE, status: 200)
    out, err = capture_io { wf.get_stream('/path', key1: 'val1') }
    assert_requested(:get, uri, headers: headers)
    assert_equal(out.strip, DUMMY_RESPONSE)
    assert_empty(err)
  end

  def test_get_stream_array_params
    uri = "#{uri_base}/path?key=val1&key=val2"
    stub_request(:get, uri).to_return(body: DUMMY_RESPONSE, status: 200)
    out, err = capture_io { wf.get_stream('/path', key: %w[val1 val2]) }
    assert_requested(:get, uri, headers: headers)
    assert_equal(out.strip, DUMMY_RESPONSE)
    assert_empty(err)
  end

  def test_get_stream_timestamp
    uri = "#{uri_base}/path?key1=val1"
    stub_request(:get, uri).to_return(body: DUMMY_RESPONSE, status: 200)

    out, err = capture_io do
      wf.get_stream('/path',
                    { key1: 'val1' },
                    { timestamp_chunks: true })
    end

    assert_requested(:get, uri, headers: headers)
    out_lines = out.split("\n")
    assert_match(/^\d{4}-\d\d-\d\d \d\d:\d\d:\d\d \+\d{4}$/, out_lines[0])
    assert_equal(out_lines[1], DUMMY_RESPONSE)
    assert_empty(err)
  end

  def test_post
    uri = "#{uri_base}/path"
    obj = { key: 'value' }
    stub_request(:post, uri).to_return(body: DUMMY_RESPONSE, status: 200)
    wf.post('/path', 'string')
    assert_requested(:post, uri, body: 'string',
                                 headers: headers.merge(POST_HEADERS))
    wf.post('/path', obj)
    assert_requested(:post, uri, body: obj.to_json,
                                 headers: headers.merge(POST_HEADERS))
  end

  def test_put
    uri = "#{uri_base}/path"
    stub_request(:put, uri).to_return(body: DUMMY_RESPONSE, status: 200)
    wf.put('/path', 'body')
    assert_requested(:put, uri, body: 'body'.to_json,
                                headers: headers.merge(JSON_POST_HEADERS))
  end

  def test_delete
    uri = "#{uri_base}/path"
    stub_request(:delete, uri).to_return(body: DUMMY_RESPONSE, status: 200)
    wf.delete('/path')
    assert_requested(:delete, uri, headers: headers)
  end

  def test_api_noop
    uri = "#{uri_base}/path"

    %w[get post put delete].each do |call|
      stub_request(call.to_sym, uri)
      wf_noop.send(call, '/path')
      refute_requested(call.to_sym, uri)
    end
  end
end
