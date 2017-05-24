#!/usr/bin/env ruby

require 'pathname'
require_relative '../spec_helper'
require_relative '../../lib/wavefront-sdk/credentials'

CONF = Pathname.new(__FILE__).dirname.realpath + 'resources' + 'test.conf'

# Test SDK base class
#
class WavefrontCredentialsTest < MiniTest::Test
  attr_reader :wf, :wf_noop, :uri_base, :headers

  def test_initialize_1
    ENV.delete('WAVEFRONT_ENDPOINT')
    ENV.delete('WAVEFRONT_TOKEN')
    wf = Wavefront::Credentials.new(file: CONF)
    o = wf.to_obj
    assert_instance_of(OpenStruct, o)
    assert_instance_of(Hash, wf.to_hash)

    assert_equal(o.creds.keys, [:token, :endpoint])
    assert_equal(o.creds[:token], '12345678-abcd-1234-abcd-123456789012')
    assert_equal(o.creds[:endpoint], 'default.wavefront.com')
  end

  def test_initialize_env_token
    ENV.delete('WAVEFRONT_ENDPOINT')
    ENV['WAVEFRONT_TOKEN'] = 'abcdefgh'
    wf = Wavefront::Credentials.new(file: CONF)
    o = wf.to_obj
    assert_instance_of(OpenStruct, o)
    assert_instance_of(Hash, wf.to_hash)

    assert_equal(o.creds.keys, [:token, :endpoint])
    assert_equal(o.creds[:token], 'abcdefgh')
    assert_equal(o.creds[:endpoint], 'default.wavefront.com')
  end

  def test_initialize_env_endpoint
    ENV.delete('WAVEFRONT_TOKEN')
    ENV['WAVEFRONT_ENDPOINT'] = 'endpoint.wavefront.com'
    wf = Wavefront::Credentials.new(file: CONF)
    o = wf.to_obj
    assert_instance_of(OpenStruct, o)
    assert_instance_of(Hash, wf.to_hash)

    assert_equal(o.creds.keys, [:token, :endpoint])
    assert_equal(o.creds[:token], '12345678-abcd-1234-abcd-123456789012')
    assert_equal(o.creds[:endpoint], 'endpoint.wavefront.com')
  end
end
