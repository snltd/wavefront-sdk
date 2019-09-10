#!/usr/bin/env ruby

require 'logger'
require_relative '../../spec_helper'
require_relative '../../../lib/wavefront-sdk/writers/core'
require_relative '../resources/dummy_points'

# rubocop:disable Style/MutableConstant
WBWT_CREDS = { endpoint: 'stub.wavefront.com', token: 'tkn' }
# rubocop:enable Style/MutableConstant

# Fake class for testing
#
class TestClassNoTags
  def creds
    WBWT_CREDS
  end

  def opts
    {}
  end

  def logger
    Logger.new(STDOUT)
  end

  def manage_conn
    true
  end
end

# Test methods common to 'write' and 'report'
#
class WavefrontCoreWriteTest < MiniTest::Test
  attr_reader :wf, :wf_tags

  def setup
    @wf = Wavefront::Writer::Core.new(TestClassNoTags.new)
  end

  def test_prefix_points
    assert_equal(%w[p1 p2 p3 p4], wf.prefix_points(%w[p1 p2 p3 p4]))
    assert_equal(%w[p1 p2 p3 p4], wf.prefix_points([%w[p1 p2 p3 p4]]))
    assert_equal(%w[p1], wf.prefix_points('p1'))
    assert_equal([{ path: 'prefix.p1' },
                  { path: 'prefix.p2' },
                  { path: 'prefix.p3' }],
                 wf.prefix_points([{ path: 'p1' },
                                   { path: 'p2' },
                                   { path: 'p3' }], 'prefix'))

    assert_equal([path: 'prefix.p1'],
                 wf.prefix_points({ path: 'p1' }, 'prefix'))
  end
end
