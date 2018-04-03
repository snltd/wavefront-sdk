#!/usr/bin/env ruby
#
require_relative '../spec_helper'
require_relative '../../lib/wavefront-sdk/exception'
require_relative '../../lib/wavefront-sdk/response'

WF_JSON = '{"status":{"result":"OK","message":"","code":200},' \
          '"response":{"items":[{"name":"test agent"}],"offset":0,' \
          '"limit":100,"totalItems":3,"moreItems":false}}'.freeze

# Unit tests for Response class
#
class WavefrontResponseTest < MiniTest::Test
  def test_initialize_good_data
    wf = Wavefront::Response.new(WF_JSON, 200)
    assert_instance_of(Wavefront::Response, wf)
    assert_respond_to(wf, :status)
    assert_respond_to(wf, :response)
    assert_respond_to(wf.response, :items)
    refute_respond_to(wf, :to_a)
    %i[code message result].each { |m| assert_respond_to(wf.status, m) }
    assert_equal(wf.status.code, 200)
    assert_instance_of(Array, wf.response.items)
  end

  def test_initialize_bad_data; end

  def test_build_response
    wf = Wavefront::Response.new(WF_JSON, 200)
    assert_equal(Map.new, wf.build_response({}))
    assert_equal(Map.new, wf.build_response([]))
    assert_equal(Map.new, wf.build_response('string'))
    assert_equal(Map.new(key: 123), wf.build_response(key: 123))
    assert_equal(123, wf.build_response(response: 123))
    assert_equal([1, 2], wf.build_response(response: [1, 2]))
    assert_equal(Map.new(key: 123),
                 wf.build_response(response: { key: 123 }))
  end
end
