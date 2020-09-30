#!/usr/bin/env ruby
# frozen_string_literal: true

require_relative '../../spec_helper'
require_relative '../../../lib/wavefront-sdk/metric_type/base'

QUEUE_START = Time.now.to_i

# Test the metric sending and queueing mechanisms shared by all
# metric types
#
class WavefrontMetricTypeBaseTest < MiniTest::Test
  attr_reader :wf, :queue

  def setup
    @wf = Wavefront::MetricType::Base.new(W_CREDS, {}, {})
    @queue = setup_queue
  end

  def setup_queue
    SizedQueue.new(10).tap do |queue|
      1.upto(10) do |i|
        queue.<< ({ path: 'test.path',
                    value: i,
                    timestamp: QUEUE_START + i,
                    source: 'testhost',
                    tags: { tag1: 'val1' } })
      end
    end
  end

  def test_setup_metric_opts
    assert_equal(
      { queue_size: 10_000,
        flush_interval: 300,
        dist_port: 40_000,
        nonblock: true,
        no_validate: false,
        suppress_errors: true,
        delta_interval: 300 }, wf.setup_metric_opts({})
    )

    assert_equal(
      { queue_size: 10_000,
        flush_interval: 600,
        dist_port: 40_000,
        delta_interval: 600,
        nonblock: true,
        no_validate: false,
        suppress_errors: true }, wf.setup_metric_opts(flush_interval: 600)
    )

    assert_equal(
      { queue_size: 10_000,
        flush_interval: 300,
        dist_port: 40_000,
        nonblock: true,
        no_validate: false,
        suppress_errors: true,
        delta_interval: 60 }, wf.setup_metric_opts(delta_interval: 60)
    )
  end

  def test_setup_writer
    assert_instance_of(Wavefront::Write, wf.setup_writer(W_CREDS, {}))
  end

  # We stub out the send methods at some point, so points are never
  # really sent.
  #
  def test_flush!
    send_method = Spy.on(wf, :send_to_wf)
    wf.flush!(queue)
    assert(send_method.has_been_called?)
    assert_equal(1, send_method.calls.size)
  end

  def test_flush_empty_queue!
    send_method = Spy.on(wf, :send_to_wf)
    wf.flush!(SizedQueue.new(1))
    refute send_method.has_been_called?
  end

  def test_send_to_wf
    send_method = Spy.on(wf, :send_to_wf)
    wf.send_to_wf(queue.to_a)
    assert(send_method.has_been_called?)
    assert_equal(1, send_method.calls.size)
  end

  # Make sure we put things back on the queue after a failure to
  # send

  def test_broken_send
    assert_equal(0, wf.queue.size)
    send_method = Spy.on(wf, :_send_to_wf).and_return(BadMocket.new)
    capture_io { wf.send_to_wf(queue.to_a) }
    assert(send_method.has_been_called?)
    assert_equal(1, send_method.calls.size)
    assert_equal(10, wf.queue.size)
  end

  def test_fill_in
    x = wf.fill_in(path: 'test.metric', value: 1)
    assert_equal('test.metric', x[:path])
    assert_equal(1, x[:value])
    assert_equal(HOSTNAME, x[:source])
    assert_instance_of(Float, x[:ts])

    x = wf.fill_in(path: 'test.metric', value: 1, ts: QUEUE_START)
    assert_equal('test.metric', x[:path])
    assert_equal(1, x[:value])
    assert_equal(HOSTNAME, x[:source])
    assert_equal(QUEUE_START, x[:ts])

    input = { path: 'test.metric',
              value: 1,
              ts: QUEUE_START,
              source: 'unit_test' }

    assert_equal(input, wf.fill_in(input))
  end
end
