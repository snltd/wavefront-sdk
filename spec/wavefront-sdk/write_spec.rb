#!/usr/bin/env ruby

require_relative '../spec_helper'
require 'minitest/autorun'
require_relative '../../lib/wavefront-sdk/write.rb'
require_relative 'resources/dummy_points'

W_CREDS = { proxy: 'wavefront', port: 2878 }.freeze

# This class is sufficiently different to the API calling classes
# that it doesn't use spec helper or inherit anything.
#
class WavefrontWriteTest < MiniTest::Test
  attr_reader :wf, :wf_noop, :wf_tags

  def setup
    @wf = Wavefront::Write.new(W_CREDS)
    @wf_noop = Wavefront::Write.new(W_CREDS, noop: true)
    @wf_tags = Wavefront::Write.new(W_CREDS, tags: TAGS)
  end

  def test_initialize
    refute(wf.opts[:tags])
    refute(wf.opts[:verbose])
    refute(wf.opts[:debug])
    refute(wf.opts[:noop])
    assert(wf_noop.opts[:noop])
    assert_equal(wf_tags.opts[:tags], TAGS)
    assert_instance_of(Wavefront::Writer::Socket, wf.writer)
  end

  def test_paths_to_deltas
    x = wf.paths_to_deltas(POINTS.dup)
    assert_equal(x.size, 2)

    x.each do |p|
      assert_instance_of(Hash, p)
      assert(p[:path].start_with?(DELTA))
    end
  end

  def test_point_array
    p1 = POINT.dup
    assert_equal(['test.metric', 123_456, 1_469_987_572, 'testhost',
                  't1="v1" t2="v2"', nil], wf.point_array(p1))

    p2 = POINT.dup.tap { |p| p.delete(:point) }
    assert_raises(StandardError) { wf.point_arrayt(p2) }

    p3 = POINT.dup.tap { |p| p.delete(:value) }
    assert_raises(StandardError) { wf.point_arrayt(p3) }

    p4 = POINT.dup.tap { |p| p.delete(:ts) }
    assert_equal(['test.metric', 123_456, nil, 'testhost',
                  't1="v1" t2="v2"', nil], wf.point_array(p4))

    p5 = POINT.dup.tap { |p| p.delete(:tags) }
    assert_equal(['test.metric', 123_456, 1_469_987_572, 'testhost',
                  nil, nil], wf.point_array(p5))
  end

  def test_hash_to_wf
    assert_equal(wf.hash_to_wf(POINT),
                 'test.metric 123456 1469987572 ' \
                 'source=testhost t1="v1" t2="v2"')
    assert_equal(wf_tags.hash_to_wf(POINT),
                 'test.metric 123456 1469987572 ' \
                 'source=testhost t1="v1" t2="v2" ' \
                 'gt1="gv1" gt2="gv2"')

    p1 = POINT.dup
    p1.delete(:ts)
    assert_equal(wf.hash_to_wf(p1),
                 'test.metric 123456 source=testhost t1="v1" t2="v2"')

    p2 = POINT.dup
    p2.delete(:tags)
    assert_equal(wf.hash_to_wf(p2),
                 'test.metric 123456 1469987572 source=testhost')

    %i[value path].each do |k|
      p3 = POINT.dup
      p3.delete(k)

      assert_raises(Wavefront::Exception::InvalidPoint) do
        wf.hash_to_wf(p3)
      end

      assert_raises(Wavefront::Exception::InvalidPoint) do
        wf_tags.hash_to_wf(p3)
      end
    end
  end
end
