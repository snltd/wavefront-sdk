#!/usr/bin/env ruby
#
require_relative '../spec_helper'
require_relative '../../lib/wavefront-sdk/exception'
require_relative '../../lib/wavefront-sdk/response'

WF_JSON = '{"status":{"result":"OK","message":"","code":200},' \
          '"response":{"items":[{"name":"test agent"}],"offset":0,' \
          '"limit":100,"totalItems":3,"moreItems":false}}'

# Unit tests for Response class

class WavefrontResponseTest < MiniTest::Test

  def test_initialize_good_data
    wf = Wavefront::Response.new(WF_JSON, 200)
    assert_instance_of(Wavefront::Response, wf)
    assert_respond_to(wf, :status)
    assert_respond_to(wf, :response)
    assert_respond_to(wf.response, :items)
    refute_respond_to(wf, :to_a)
    [:code, :message, :result].each { |m| assert_respond_to(wf.status, m) }
    assert_equal(wf.status.code, 200)
    assert_instance_of(Array, wf.response.items)
  end

  def test_initialize_bad_data
    assert_raises(Wavefront::Exception::InvalidResponse) do
      Wavefront::Response.new('merp', 200)
    end

    assert_raises(Wavefront::Exception::InvalidResponse) do
      Wavefront::Response.new(
        '{"status":{"result":"OK","message":"","code":200}', 200)
    end

    assert_raises(Wavefront::Exception::InvalidResponse) do
      Wavefront::Response.new(
        '{"status":{"result":"OK","message":"","code":200}', 200)
    end

    assert_raises(Wavefront::Exception::InvalidResponse) do
      Wavefront::Response.new(
        '{"response":{"items":[{"name":"test agent"}],"offset":0 }', 200)
    end
  end
end
