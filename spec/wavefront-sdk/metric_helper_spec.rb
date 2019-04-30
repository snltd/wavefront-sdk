#!/usr/bin/env ruby

require_relative '../spec_helper'
require_relative '../../lib/wavefront-sdk/metric_helper'

ND_CREDS = { proxy: 'wavefront' }.freeze
WH_TAGS  = { t1: 'v1', t2: 'v2' }.freeze

# Tests for the MetricHelper class.
#
class WavefrontMetricHelperTest < MiniTest::Test
  attr_reader :wf, :wfd

  def setup
    @wf = Wavefront::MetricHelper.new(ND_CREDS, {})
  end

  def test_classes
    assert_instance_of(Wavefront::MetricType::Counter, wf.counter)
    assert_instance_of(Wavefront::MetricType::Gauge, wf.gauge)
    assert_instance_of(Wavefront::MetricType::Distribution, wf.dist)
    assert_instance_of(SizedQueue, wf.counter.queue)
    assert_instance_of(SizedQueue, wf.gauge.queue)
    assert_instance_of(SizedQueue, wf.dist.queue)
  end

  def add_points
    1.upto(10).each do |i|
      wf.gauge.q('test.gauge', i)
      wf.counter.q('test.counter', 1)
      wf.dist.q('test.dist', :m, [1, 2, 3])
    end
  end

  def test_flush!
    add_points
    refute_empty wf.gauge.queue
    refute_empty wf.counter.queue
    refute_empty wf.dist.queue
    g_send = Spy.on(wf.gauge, :_send_to_wf).and_return(Mocket.new)
    c_send = Spy.on(wf.counter, :_send_to_wf).and_return(Mocket.new)
    d_send = Spy.on(wf.dist, :_send_to_wf).and_return(Mocket.new)
    wf.flush!
    assert_empty wf.gauge.queue
    assert_empty wf.counter.queue
    assert_empty wf.dist.queue
    assert g_send.has_been_called?
    assert d_send.has_been_called?
    assert c_send.has_been_called?
    refute wf.gauge.flush_thr.stop?
    refute wf.counter.flush_thr.stop?
    refute wf.dist.flush_thr.stop?
  end

  def test_close!
    add_points
    refute_empty wf.gauge.queue
    refute_empty wf.counter.queue
    refute_empty wf.dist.queue
    g_send = Spy.on(wf.gauge, :_send_to_wf).and_return(Mocket.new)
    c_send = Spy.on(wf.counter, :_send_to_wf).and_return(Mocket.new)
    d_send = Spy.on(wf.dist, :_send_to_wf).and_return(Mocket.new)
    wf.close!
    assert_empty wf.gauge.queue
    assert_empty wf.counter.queue
    assert_empty wf.dist.queue
    assert g_send.has_been_called?
    assert d_send.has_been_called?
    assert c_send.has_been_called?
    assert wf.gauge.flush_thr.stop?
    assert wf.counter.flush_thr.stop?
    assert wf.dist.flush_thr.stop?
  end
end
