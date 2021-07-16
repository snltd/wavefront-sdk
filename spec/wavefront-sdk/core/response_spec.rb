#!/usr/bin/env ruby
# frozen_string_literal: true

require 'json'
require_relative '../../spec_helper'
require_relative '../../../lib/wavefront-sdk/core/exception'
require_relative '../../../lib/wavefront-sdk/core/response'

GOOD_RESP = '{"status":{"result":"OK","message":"","code":200},' \
            '"response":{"items":[{"name":"test agent"}],"offset":0,' \
            '"limit":100,"totalItems":3,"moreItems":false}}'

BAD_RESP = "error='not_found'
message='resource cannot be found'
trackingId=eca22ddc-848b-4e67-876a-366145c8a759"

ERR_RESP = { error: 'HTTP 415 Unsupported Media Type',
             trackingId: 'ce231eaf-8d0e-4138-a82d-12725376a3b0' }.to_json

# Unit tests for Response class. Also indirectly tests the Status
# type.
#
class WavefrontResponseTest < MiniTest::Test
  attr_reader :wfg, :wfb, :wfe

  def setup
    @wfg = Wavefront::Response.new(GOOD_RESP, 200)
    @wfb = Wavefront::Response.new(BAD_RESP, 404)
    @wfe = Wavefront::Response.new(ERR_RESP, 415)
  end

  def test_initialize_good_data
    assert_instance_of(Wavefront::Response, wfg)
    assert_respond_to(wfg, :status)
    assert_respond_to(wfg, :response)
    refute_respond_to(wfg, :to_a)
    assert_respond_to(wfg.response, :items)
    assert_instance_of(Array, wfg.response.items)
    assert_instance_of(Wavefront::Type::Status, wfg.status)
    assert_equal(200, wfg.status.code)
    assert_equal('OK', wfg.status.result)
    assert_instance_of(String, wfg.status.message)
    assert_empty(wfg.status.message)
    assert wfg.ok?
    refute wfg.more_items?
    refute wfg.next_item
  end

  def test_initialize_bad_data
    assert_instance_of(Wavefront::Response, wfb)
    assert_respond_to(wfb, :status)
    assert_respond_to(wfb, :response)
    refute_respond_to(wfb, :to_a)
    refute_respond_to(wfb.response, :items)
    assert_instance_of(Wavefront::Type::Status, wfb.status)
    assert_equal(404, wfb.status.code)
    assert_equal('ERROR', wfb.status.result)
    assert_instance_of(String, wfb.status.message)
    assert_match(/error='not_found'/, wfb.status.message)
    refute wfb.ok?
    refute wfb.more_items?
    refute wfb.next_item
  end

  def test_initialize_err_data
    assert_instance_of(Wavefront::Response, wfe)
    assert_respond_to(wfe, :status)
    assert_respond_to(wfe, :response)
    refute_respond_to(wfe, :to_a)
    refute_respond_to(wfe.response, :items)
    assert_instance_of(Wavefront::Type::Status, wfe.status)
    assert_equal(415, wfe.status.code)
    assert_equal('ERROR', wfe.status.result)
    assert_equal('HTTP 415 Unsupported Media Type', wfe.status.message)
    refute wfe.ok?
    refute wfe.more_items?
    refute wfe.next_item
  end

  # This is a private method, so we test its public interface
  #
  def test_build_response
    assert_equal(Map.new, Wavefront::Response.new('', 200).response)
    assert_equal(Map.new, Wavefront::Response.new({}, 200).response)
    assert_equal(Map.new, Wavefront::Response.new([], 200).response)
    assert_equal(Map.new(message: 'string', code: 200),
                 Wavefront::Response.new('string', 200).response)
    assert_equal(123, Wavefront::Response.new({ response: 123 }.to_json,
                                              200).response)
  end

  def test_to_s
    assert_instance_of(String, wfg.to_s)
    assert_match(/:code=>200/, wfg.to_s)
    assert_match(/"limit"=>100/, wfg.to_s)
  end
end
