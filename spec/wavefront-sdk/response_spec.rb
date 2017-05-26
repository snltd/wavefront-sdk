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
    wf = Wavefront::Response::Base.new(WF_JSON)
    assert_instance_of(Wavefront::Response::Base, wf)
    assert_respond_to(wf, :status)
    assert_respond_to(wf, :response)
    refute_respond_to(wf, :to_a)
    [:code, :message, :result].each { |m| assert_respond_to(wf.status, m) }
    assert_equal(wf.status.code, 200)
    assert_instance_of(Hash, wf.response)
    wf.response.keys.each { |k| assert_instance_of(Symbol, k) }
  end

  def test_initialize_bad_data
    assert_raises(Wavefront::Exception::InvalidResponse) do
      Wavefront::Response::Base.new('merp')
    end

    assert_raises(Wavefront::Exception::InvalidResponse) do
      Wavefront::Response::Base.new(
        '{"status":{"result":"OK","message":"","code":200}')
    end

    assert_raises(Wavefront::Exception::InvalidResponse) do
      Wavefront::Response::Base.new(
        '{"status":{"result":"OK","message":"","code":200}')
    end

    assert_raises(Wavefront::Exception::InvalidResponse) do
      Wavefront::Response::Base.new(
        '{"response":{"items":[{"name":"test agent"}],"offset":0 }')
    end
  end
end
