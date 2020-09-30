#!/usr/bin/env ruby
# frozen_string_literal: true

require_relative '../../spec_helper'
require_relative '../../../lib/wavefront-sdk/metric_type/counter'

T_QUEUE_START = 1_555_360_340
T_QUEUE_END   = T_QUEUE_START + 10
T_QUEUE_CALL  = T_QUEUE_END + 10

# Test for counter specifics. The sending mechanism is tested by
# base_spec
#
class WavefrontMetricTypeCounterTest < MiniTest::Test
  attr_reader :wf, :queue_a

  def setup(opts = {})
    @wf = Wavefront::MetricType::Counter.new(W_CREDS, {}, opts)
    setup_queue
    @queue_a = wf.queue.to_a
    setup_queue
  end

  def setup_queue
    1.upto(10) do |i|
      wf.qq(path: 'test.path.a',
            value: i,
            ts: T_QUEUE_START + i,
            source: 'testhost',
            tags: { tag1: 'val1' })
      wf.qq(path: 'test.path.b',
            value: 10 * i,
            ts: T_QUEUE_START + i,
            source: 'unit_test',
            tags: { tag1: 'val2' })
    end
  end

  def test_setup_writer
    assert_instance_of(Wavefront::Write, wf.setup_writer(W_CREDS, {}))
  end

  def test_add_point_quick
    wf.queue.clear
    wf.q('test.metric', 10)
    assert_equal(1, wf.queue.length)
    x = wf.queue.pop
    assert_instance_of(Array, x[:key])
    assert_equal('test.metric', x[:key][0])
    assert_kind_of(Numeric, x[:ts])
    assert_equal({}, x[:key][2])
    assert_equal(10, x[:value])
  end

  def test_add_point_hash
    wf.queue.clear
    wf.qq(path: 'new.metric',
          value: 1.5,
          ts: T_QUEUE_START,
          source: 'unit_test',
          tags: { key1: 'val1' })
    assert_equal(1, wf.queue.length)
    assert_equal({ key: ['new.metric', 'unit_test', { key1: 'val1' }],
                   ts: T_QUEUE_START,
                   value: 1.5 }, wf.queue.pop)
  end

  def test_to_wf
    assert_equal([{ path: 'test.path.a',
                    source: 'testhost',
                    ts: T_QUEUE_CALL,
                    value: 55,
                    tags: { tag1: 'val1' } },
                  { path: 'test.path.b',
                    source: 'unit_test',
                    ts: T_QUEUE_CALL,
                    value: 550,
                    tags: { tag1: 'val2' } }],
                 wf.to_wf(wf.queue.to_a, T_QUEUE_CALL))

    1.upto(12) do |i|
      setup(flush_interval: i * 100, delta_interval: i)
      x = wf.to_wf(wf.queue.to_a, T_QUEUE_CALL)
      path_a = x.select { |p| p[:path] == 'test.path.a' }
      path_b = x.select { |p| p[:path] == 'test.path.b' }
      assert_instance_of(Array, path_a)
      assert_instance_of(Array, path_b)
      assert_equal(55, path_a.map { |p| p[:value] }.inject(:+))
      assert_equal(550, path_b.map { |p| p[:value] }.inject(:+))
    end
  end

  def test_bucketed_data
    assert_equal([[queue_a, T_QUEUE_END]],
                 wf.bucketed_data(queue_a, T_QUEUE_END, 300))
    assert_equal(5, wf.bucketed_data(queue_a, T_QUEUE_END, 2).size)
  end

  def test_points_in_range
    assert_equal(4, wf.points_in_range(queue_a, T_QUEUE_END, 2).size)
    assert_equal(20, wf.points_in_range(queue_a, T_QUEUE_END, 200).size)
    assert_equal(0, wf.points_in_range(queue_a, T_QUEUE_END + 100, 10).size)
  end

  def test_metric_bucket_to_point
    data = [{ key: ['test.path', 'testhost', { tag1: 'val1' }],
              value: 9,
              ts: T_QUEUE_END - 1 },
            { key: ['test.path', 'testhost', { tag1: 'val1' }],
              value: 10,
              ts: T_QUEUE_END }]

    assert_equal([{ path: 'test.path',
                    source: 'testhost',
                    ts: T_QUEUE_CALL,
                    value: 19,
                    tags: { tag1: 'val1' } }],
                 wf.bucket_to_point(data, T_QUEUE_CALL))

    assert_equal([], wf.metric_bucket_to_point([], T_QUEUE_CALL))
  end
end
