#!/usr/bin/env ruby

require_relative '../spec_helper'
require_relative '../../lib/wavefront-sdk/distribution'

# Most of the distribution methods are inherited from the Write
# class so they aren't tested again here.
#
class WavefrontDistributionTest < MiniTest::Test
  attr_reader :wf

  def setup
    @wf = Wavefront::Distribution.new(W_CREDS)
  end

  def test_mk_distribution
    assert_equal([[4, 1], [2, 3], [1, 2], [2, 6]].sort,
                 wf.mk_distribution([1, 6, 3, 1, 1, 3, 2, 6, 1]).sort)
  end

  def test_mk_wf_distribution
    assert_equal('#4 1.0 #2 3.0 #1 2.0 #2 6.0',
                 wf.mk_wf_distribution([1, 1, 1, 1, 3, 3, 2, 6, 6]))
    assert_equal('#4 1.0 #2 3.0 #1 2.0 #2 6.0',
                 wf.mk_wf_distribution('1 1 1 1 3 3 2 6 6'))
    assert_equal('#4 1.0 #2 3.0 #1 2.0 #2 6.0',
                 wf.mk_wf_distribution(1, 1, 1, 1, 3, 3, 2, 6, 6))
    assert_equal('#4 1.0 #2 3.0 #1 2.0 #2 6.0',
                 wf.mk_wf_distribution([1, 1, 1], [1, 3, 3, 2, 6, 6]))
  end

  def test_hash_to_wf
    assert_equal(wf.hash_to_wf(distribution),
                 '!M 1538865613 #5 11 #15 2.533 #8 -15 #12 1000000.0 ' \
                 'test.distribution source=minitest ' \
                 'tag1="val1" tag2="val2"')

    d2 = distribution.dup
    d2[:tags] = {}

    assert_equal(wf.hash_to_wf(d2),
                 '!M 1538865613 #5 11 #15 2.533 #8 -15 #12 1000000.0 ' \
                 'test.distribution source=minitest')

    d3 = distribution.dup
    d3[:ts] = Time.at(1_538_865_613)
    d3 = d3.tap { |d| d.delete(:source) }

    assert_equal(wf.hash_to_wf(d3),
                 '!M 1538865613 #5 11 #15 2.533 #8 -15 #12 1000000.0 ' \
                 "test.distribution source=#{Socket.gethostname} " \
                 'tag1="val1" tag2="val2"')

    bad_dist = distribution.dup
    bad_dist.delete(:interval)

    assert_raises(Wavefront::Exception::InvalidDistribution) do
      wf.hash_to_wf(bad_dist)
    end
  end

  def test_array2dist
    assert_equal(wf.array2dist([[1, 4], [6, 5]]), '#1 4 #6 5')
    assert_equal(wf.array2dist([[12, 4.235]]), '#12 4.235')
  end

  def distribution
    { interval: :m,
      path:     'test.distribution',
      value:    [[5, 11], [15, 2.533], [8, -15], [12, 1e6]],
      ts:       1_538_865_613,
      source:   'minitest',
      tags:     { tag1: 'val1', tag2: 'val2' } }
  end
end
