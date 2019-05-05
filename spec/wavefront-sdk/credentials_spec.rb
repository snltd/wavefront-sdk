#!/usr/bin/env ruby

require 'pathname'
require_relative '../spec_helper'
require_relative '../../lib/wavefront-sdk/credentials'

CONF1 = RESOURCE_DIR + 'test.conf'
CONF2 = RESOURCE_DIR + 'test2.conf'

# Test SDK base class end-to-end
#
class WavefrontCredentialsTest < MiniTest::Test
  def test_initialize_1
    ENV.delete('WAVEFRONT_ENDPOINT')
    ENV.delete('WAVEFRONT_TOKEN')
    c = Wavefront::Credentials.new(file: CONF1)
    assert_instance_of(Wavefront::Credentials, c)
    assert_instance_of(Map, c.creds)
    assert_instance_of(Map, c.proxy)
    assert_instance_of(Map, c.config)
    assert_instance_of(Map, c.all)

    assert_equal(%w[token endpoint], c.creds.keys)
    assert_equal('12345678-abcd-1234-abcd-123456789012', c.creds[:token])
    assert_equal('default.wavefront.com', c.creds[:endpoint])
  end

  def test_initialize_env_token
    ENV.delete('WAVEFRONT_ENDPOINT')
    ENV['WAVEFRONT_TOKEN'] = 'abcdefgh'
    c = Wavefront::Credentials.new(file: CONF1)
    assert_instance_of(Wavefront::Credentials, c)
    assert_instance_of(Map, c.creds)
    assert_instance_of(Map, c.proxy)
    assert_instance_of(Map, c.config)
    assert_instance_of(Map, c.all)

    assert_equal(%w[token endpoint], c.creds.keys)
    assert_equal('abcdefgh', c.creds[:token])
    assert_equal('default.wavefront.com', c.creds[:endpoint])
  end

  def test_initialize_env_endpoint
    ENV.delete('WAVEFRONT_TOKEN')
    ENV['WAVEFRONT_ENDPOINT'] = 'endpoint.wavefront.com'
    c = Wavefront::Credentials.new(file: CONF1)
    assert_instance_of(Wavefront::Credentials, c)
    assert_instance_of(Map, c.creds)
    assert_instance_of(Map, c.proxy)
    assert_instance_of(Map, c.config)
    assert_instance_of(Map, c.all)

    assert_equal(%w[token endpoint], c.creds.keys)
    assert_equal('12345678-abcd-1234-abcd-123456789012', c.creds[:token])
    assert_equal('endpoint.wavefront.com', c.creds[:endpoint])
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
    assert_equal(raw, wf.env_override(raw))
  end

  def test_env_override_env_endpoint
    ENV['WAVEFRONT_ENDPOINT'] = 'env_ep'

    assert_equal(
      { endpoint: 'env_ep', token: 'raw_tok', proxy: 'raw_proxy' },
      wf.env_override(raw)
    )
  end

  def test_env_override_env_endpoint_and_token
    ENV['WAVEFRONT_ENDPOINT'] = 'env_ep'
    ENV['WAVEFRONT_TOKEN'] = 'env_tok'

    assert_equal(
      { endpoint: 'env_ep', token: 'env_tok', proxy: 'raw_proxy' },
      wf.env_override(raw)
    )
  end

  def test_env_override_env_proxy
    ENV['WAVEFRONT_PROXY'] = 'env_proxy'
    x = wf.env_override(raw)

    assert_instance_of(Hash, x)
    assert_equal(
      { endpoint: 'raw_ep', token: 'raw_tok', proxy: 'env_proxy' },
      x
    )
  end

  def test_populate
    wf.populate(raw)
    config = wf.instance_variable_get('@config')
    creds = wf.instance_variable_get('@creds')
    proxy = wf.instance_variable_get('@proxy')

    assert_instance_of(Map, config)
    assert_equal('raw_proxy', config.proxy)
    assert_equal('raw_ep', config.endpoint)

    assert_instance_of(Map, creds)
    assert_equal('raw_ep', creds.endpoint)
    assert_equal('raw_tok', creds.token)
    refute creds[:proxy]

    assert_instance_of(Map, proxy)
    assert_equal('raw_proxy', config.proxy)
    refute proxy[:endpoint]
  end

  def test_cred_files_no_opts
    x = wf.cred_files
    assert_instance_of(Array, x)
    assert_equal(3, x.length)
    x.each { |p| assert_instance_of(Pathname, p) }
    assert_includes(x, Pathname.new('/etc/wavefront/credentials'))
    assert_includes(x, Pathname.new(ENV['HOME']) + '.wavefront')
    assert_includes(x, Pathname.new(ENV['HOME']) + '.wavefront.conf')
  end

  def test_cred_files_opts
    x = wf.cred_files(file: '/test/file')
    assert_instance_of(Array, x)
    assert_equal(1, x.length)
    assert_equal(Array(Pathname.new('/test/file')), x)
  end

  def test_load_from_file
    assert_equal({},
                 wf.load_from_file(
                   [Pathname.new('/no/file/1'), Pathname.new('/no/file/2')]
                 ))

    assert_equal({ file: CONF1 }, wf.load_from_file([CONF1], 'noprofile'))

    x = wf.load_from_file([CONF2, CONF1], 'default')
    assert_instance_of(Hash, x)
    assert_equal(5, x.keys.size)
    assert_equal('wavefront.localnet', x[:proxy])

    %i[token endpoint proxy sourceformat file].each do |k|
      assert_includes(x.keys, k)
    end

    y = wf.load_from_file([CONF2, CONF1], 'other')
    assert_instance_of(Hash, y)
    %i[token endpoint proxy file].each { |k| assert_includes(y.keys, k) }
    assert_equal(4, y.keys.size)
    assert_equal('otherwf.localnet', y[:proxy])

    z = wf.load_from_file([CONF1, CONF2], 'default')
    assert_instance_of(Hash, z)
    %i[token endpoint proxy file].each { |k| assert_includes(z.keys, k) }
    assert_equal(4, z.keys.size)
    assert_equal('wavefront.lab', z[:proxy])
    assert_equal('somewhere.wavefront.com', z[:endpoint])
  end

  def test_load_profile
    assert_equal({}, wf.load_profile(CONF1, 'nosuchprofile'))
    assert_instance_of(Hash, wf.load_profile(CONF1, 'default'))

    assert_raises Wavefront::Exception::InvalidConfigFile do
      wf.load_profile('/no/such/file')
    end

    assert_raises Wavefront::Exception::InvalidConfigFile do
      wf.load_profile(RESOURCE_DIR)
    end

    assert_raises Wavefront::Exception::InvalidConfigFile do
      wf.load_profile(RESOURCE_DIR + 'malformed.conf')
    end
  end
end
