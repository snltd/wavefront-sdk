#!/usr/bin/env ruby

require 'minitest/autorun'
require_relative '../../lib/wavefront-sdk/distribution'

W_CREDS = { proxy: 'wavefront', port: 2878 }.freeze

DIST = {
  interval: :m,
  path:     'test.distribution',
  values:   [[5, 11], [15, 2.533], [8, -15], [12, 1e6]],
  ts:       1_538_865_613,
  source:   'minitest',
  tags:     { tag1: 'val1', tag2: 'val2' }
}.freeze

# Most of the distribution methods are inherited from the Write
# class so they aren't tested again here.
#
class WavefrontDistributionTest < MiniTest::Test
  attr_reader :wf, :wf_noop, :wf_tags

  def setup
    @wf = Wavefront::Distribution.new(W_CREDS)
  end

  def test_hash_to_wf
    assert_equal(wf.hash_to_wf(DIST),
                 '!M 1538865613 #5 11 #15 2.533 #8 -15 #12 1000000.0 ' \
                 'test.distribution source=minitest ' \
                 'tag1="val1" tag2="val2"')

    d2 = DIST.dup
    d2[:tags] = {}

    assert_equal(wf.hash_to_wf(d2),
                 '!M 1538865613 #5 11 #15 2.533 #8 -15 #12 1000000.0 ' \
                 'test.distribution source=minitest')

    d3 = DIST.dup
    d3[:ts] = Time.at(1_538_865_613)
    d3 = d3.tap { |d| d.delete(:source) }

    assert_equal(wf.hash_to_wf(d3),
                 '!M 1538865613 #5 11 #15 2.533 #8 -15 #12 1000000.0 ' \
                 "test.distribution source=#{Socket.gethostname} " \
                 'tag1="val1" tag2="val2"')
  end

  def test_dist_value_string
    assert_equal(wf.dist_value_string([[1, 4], [6, 5]]), '#1 4 #6 5')
    assert_equal(wf.dist_value_string([[12, 4.235]]), '#12 4.235')
  end
end

# A mock socket
#
class Mocket
  def puts(socket); end

  def close; end
end
