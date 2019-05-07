#!/usr/bin/env ruby

require_relative '../../spec_helper'
require_relative '../../../lib/wavefront-sdk/metric_type/distribution'

QUEUE_DIST = { key:   ['test.metric', 'unit_test', :m, { tag1: 'val 1' }],
               ts:    1_556_210_452,
               value: [1, 1, 2, 3, 4, 4] }.freeze

WF_DIST = { path:     'test.metric',
            interval: :m,
            ts:       1_556_210_452,
            value:    [[2, 1], [1, 2], [1, 3], [2, 4]],
            source:   'unit_test',
            tags:     { tag1: 'val 1' } }.freeze

# Test for distribution specifics. The sending mechanism is tested
# by base_spec
#
class WavefrontMetricTypeDistributionTest < MiniTest::Test
  attr_reader :wf

  def setup(opts = {})
    @wf = Wavefront::MetricType::Distribution.new(W_CREDS, {}, opts)
  end

  def test_setup_writer
    assert_instance_of(Wavefront::Distribution,
                       wf.setup_writer(W_CREDS, {}))
  end

  def test_proxy_port
    assert_equal(40_000, wf.writer.creds[:port])

    wf2 = Wavefront::MetricType::Distribution.new(W_CREDS, {},
                                                  dist_port: 40_001)
    assert_equal(40_001, wf2.writer.creds[:port])
  end

  def test_qeueing
    wf.queue.clear
    wf.q('test.metric', :m, [1, 1, 2, 3, 4, 4], tag1: 'val 1')
    assert_equal(1, wf.queue.length)
    x = wf.queue.pop
    assert_equal(['test.metric', HOSTNAME, :m, { tag1: 'val 1' }],
                 x[:key])
    assert_equal([1, 1, 2, 3, 4, 4], x[:value])
  end

  def test_to_wf
    assert_equal([WF_DIST], wf.to_wf([QUEUE_DIST]))
  end

  def test_unpack_distribution
    assert_equal([], wf.unpack_distribution([]))
    assert_equal([1, 2, 3, 4], wf.unpack_distribution([1, 2, 3, 4]))
    assert_equal([1, 1, 2, 3, 3, 3],
                 wf.unpack_distribution([[2, 1], [1, 2], [3, 3]]))
  end

  def test_q
    x = wf.q('test.metric', :m, [1, 1, 2, 3, 4, 4], tag1: 'val 1')

    assert_instance_of(Array, x)
    assert_equal(1, x.size)

    y = x[0]

    assert_equal('test.metric', y[:path])
    assert_equal(:m, y[:interval])
    assert_equal([1, 1, 2, 3, 4, 4], y[:value])
    assert_equal(HOSTNAME, y[:source])
    assert_equal({ tag1: 'val 1' }, y[:tags])
    assert_kind_of(Numeric, y[:ts])
  end

  def test_ready_point
    assert_equal(QUEUE_DIST, wf.ready_point(WF_DIST))
  end
end
