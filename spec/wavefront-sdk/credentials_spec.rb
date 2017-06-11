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
    c = Wavefront::Credentials.new(file: CONF)
    assert_instance_of(Wavefront::Credentials, c)
    assert_instance_of(Map, c.creds)
    assert_instance_of(Map, c.proxy)
    assert_instance_of(Map, c.config)

    assert_equal(c.creds.keys, %w(token endpoint))
    assert_equal(c.creds[:token], '12345678-abcd-1234-abcd-123456789012')
    assert_equal(c.creds[:endpoint], 'default.wavefront.com')
  end

  def test_initialize_env_token
    ENV.delete('WAVEFRONT_ENDPOINT')
    ENV['WAVEFRONT_TOKEN'] = 'abcdefgh'
    c = Wavefront::Credentials.new(file: CONF)
    assert_instance_of(Wavefront::Credentials, c)
    assert_instance_of(Map, c.creds)
    assert_instance_of(Map, c.proxy)
    assert_instance_of(Map, c.config)

    assert_equal(c.creds.keys, %w(token endpoint))
    assert_equal(c.creds[:token], 'abcdefgh')
    assert_equal(c.creds[:endpoint], 'default.wavefront.com')
  end

  def test_initialize_env_endpoint
    ENV.delete('WAVEFRONT_TOKEN')
    ENV['WAVEFRONT_ENDPOINT'] = 'endpoint.wavefront.com'
    c = Wavefront::Credentials.new(file: CONF)
    assert_instance_of(Wavefront::Credentials, c)
    assert_instance_of(Map, c.creds)
    assert_instance_of(Map, c.proxy)
    assert_instance_of(Map, c.config)

    assert_equal(c.creds.keys, %w(token endpoint))
    assert_equal(c.creds[:token], '12345678-abcd-1234-abcd-123456789012')
    assert_equal(c.creds[:endpoint], 'endpoint.wavefront.com')
  end
end
