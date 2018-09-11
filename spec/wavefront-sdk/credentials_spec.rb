#!/usr/bin/env ruby

require 'pathname'
require_relative '../spec_helper'
require_relative '../../lib/wavefront-sdk/credentials'

CONF = Pathname.new(__FILE__).dirname.realpath + 'resources' + 'test.conf'
CONF2 = Pathname.new(__FILE__).dirname.realpath + 'resources' + 'test2.conf'

# Test SDK base class end-to-end
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

    assert_equal(c.creds.keys, %w[token endpoint])
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

    assert_equal(c.creds.keys, %w[token endpoint])
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

    assert_equal(c.creds.keys, %w[token endpoint])
    assert_equal(c.creds[:token], '12345678-abcd-1234-abcd-123456789012')
    assert_equal(c.creds[:endpoint], 'endpoint.wavefront.com')
  end
end

# Test individual methods. We must override the constructor to do
# this.
#
class Giblets < Wavefront::Credentials
  def initialize; end
end

# And here are the tests
#
class GibletsTest < MiniTest::Test
  attr_reader :wf, :raw

  def setup
    @wf = Giblets.new
    @raw = { endpoint: 'raw_ep', token: 'raw_tok', proxy: 'raw_proxy' }
    clear_env_vars
  end

  def clear_env_vars
    %w[WAVEFRONT_ENDPOINT WAVEFRONT_TOKEN WAVEFRONT_PROXY].each do |ev|
      ENV.delete(ev)
    end
  end

  def test_env_override_noenvs
    assert_equal(wf.env_override(raw), raw)
  end

  def test_env_override_env_endpoint
    ENV['WAVEFRONT_ENDPOINT'] = 'env_ep'

    assert_equal(wf.env_override(raw),
                 endpoint: 'env_ep', token: 'raw_tok', proxy: 'raw_proxy')
  end

  def test_env_override_env_endpoint_and_token
    ENV['WAVEFRONT_ENDPOINT'] = 'env_ep'
    ENV['WAVEFRONT_TOKEN'] = 'env_tok'

    assert_equal(wf.env_override(raw),
                 endpoint: 'env_ep', token: 'env_tok', proxy: 'raw_proxy')
  end

  def test_env_override_env_proxy
    ENV['WAVEFRONT_PROXY'] = 'env_proxy'
    x = wf.env_override(raw)

    assert_instance_of(Hash, x)
    assert_equal(x, endpoint: 'raw_ep', token: 'raw_tok', proxy:
                      'env_proxy')
  end

  def test_populate
    wf.populate(raw)
    config = wf.instance_variable_get('@config')
    creds = wf.instance_variable_get('@creds')
    proxy = wf.instance_variable_get('@proxy')

    assert_instance_of(Map, config)
    assert_equal(config.proxy, 'raw_proxy')
    assert_equal(config.endpoint, 'raw_ep')

    assert_instance_of(Map, creds)
    assert_equal(creds.endpoint, 'raw_ep')
    assert_equal(creds.token, 'raw_tok')
    refute creds[:proxy]

    assert_instance_of(Map, proxy)
    assert_equal(config.proxy, 'raw_proxy')
    refute proxy[:endpoint]
  end

  def test_cred_files_no_opts
    x = wf.cred_files
    assert_instance_of(Array, x)
    assert_equal(x.length, 2)
    x.each { |p| assert_instance_of(Pathname, p) }
    assert_includes(x, Pathname.new('/etc/wavefront/credentials'))
    assert_includes(x, Pathname.new(ENV['HOME']) + '.wavefront')
  end

  def test_cred_files_opts
    x = wf.cred_files(file: '/test/file')
    assert_instance_of(Array, x)
    assert_equal(x.length, 1)
    assert_equal(x, Array(Pathname.new('/test/file')))
  end

  def test_load_from_file
    assert_equal(wf.load_from_file(
                   [Pathname.new('/no/file/1'), Pathname.new('/no/file/2')]
                 ), {})

    assert_equal(wf.load_from_file([CONF], 'noprofile'),
                 file: CONF)

    x = wf.load_from_file([CONF2, CONF], 'default')
    assert_instance_of(Hash, x)
    assert_equal(x.keys.size, 5)
    assert_equal(x[:proxy], 'wavefront.localnet')

    %i[token endpoint proxy sourceformat file].each do |k|
      assert_includes(x.keys, k)
    end

    y = wf.load_from_file([CONF2, CONF], 'other')
    assert_instance_of(Hash, y)
    %i[token endpoint proxy file].each { |k| assert_includes(y.keys, k) }
    assert_equal(y.keys.size, 4)
    assert_equal(y[:proxy], 'otherwf.localnet')

    z = wf.load_from_file([CONF, CONF2], 'default')
    assert_instance_of(Hash, z)
    %i[token endpoint proxy file].each { |k| assert_includes(z.keys, k) }
    assert_equal(z.keys.size, 4)
    assert_equal(z[:proxy], 'wavefront.lab')
    assert_equal(z[:endpoint], 'somewhere.wavefront.com')
  end
end
