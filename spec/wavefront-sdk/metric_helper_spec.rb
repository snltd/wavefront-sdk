#!/usr/bin/env ruby

require 'minitest/autorun'
require 'spy'
require 'spy/integration'
require_relative '../spec_helper'
require_relative '../../lib/wavefront-sdk/metric_helper'

ND_CREDS = { proxy: 'wavefront' }.freeze
D_CREDS  = { proxy: 'wavefront', dist_port: 40_000 }.freeze
WH_TAGS  = { t1: 'v1', t2: 'v2' }.freeze

# Tests for the MetricHelper class.
#
# rubocop:disable Style/NumericLiterals
class WavefrontMetricHelperTest < MiniTest::Test
  attr_reader :wf, :wfd

  def setup
    @wf  = Wavefront::MetricHelper.new(D_CREDS, {})
    @wfd = Wavefront::MetricHelper.new(ND_CREDS, {})
  end

  def test_gauge_1
    wf.gauge('test.gauge', 123)
    b = wf.buf
    refute_empty(b[:gauges])
    assert_empty(b[:counters])
    assert_instance_of(Array, b[:gauges])
    assert_equal(1, b[:gauges].size)
    assert_equal(123, b[:gauges][0][:value])
  end

  def test_gauge_tags
    wf.gauge('test.gauge', 9.5, WH_TAGS)
    b = wf.buf
    refute_empty(b[:gauges])
    assert_empty(b[:counters])
    assert_instance_of(Array, b[:gauges])
    assert_equal(1, b[:gauges].size)
    assert_equal(9.5, b[:gauges][0][:value])
    assert_equal(WH_TAGS, b[:gauges][0][:tags])
  end

  def test_counter
    wf.counter('test.counter')
    wf.counter('test.counter')
    wf.counter('test.counter', 2)
    b = wf.buf
    assert_empty(b[:gauges])
    refute_empty(b[:counters])
    assert_instance_of(Hash, b[:counters])
    assert_equal(4, b[:counters][['test.counter', nil]])
  end

  def test_counter_tags
    wf.counter('test.counter')
    wf.counter('test.counter', 1, WH_TAGS)
    wf.counter('test.counter', 2)
    wf.counter('test.counter', 3, WH_TAGS)
    b = wf.buf
    assert_empty(b[:gauges])
    refute_empty(b[:counters])
    assert_instance_of(Hash, b[:counters])
    assert_equal(3, b[:counters][['test.counter', nil]])
    assert_equal(4, b[:counters][['test.counter', WH_TAGS]])
  end

  def test_dist_nodist
    refute wf.buf.key?(:dists)
  end

  def test_dist
    true
  end

  def test_gauges_to_wf
    input = [{ path: 'm1.p', ts: 1548636080, value: 0 },
             { path: 'm1.p', ts: 1548636081, value: 1 },
             { path: 'm2.p', ts: 1548636081, value: 9 }]

    assert_equal(input, wf.gauges_to_wf(input))
  end

  def test_counters_to_wf
    input = { ['test.counter1', nil]     => 7,
              ['test.counter1', WH_TAGS] => 8,
              ['test.counter2', nil]     => 9 }

    out = wf.counters_to_wf(input)
    assert_instance_of(Array, out)
    assert_equal(3, out.size)
    out.each { |o| assert_instance_of(Hash, o) }
    assert_equal('test.counter1', out.first[:path])
    assert_equal(9, out.last[:value])
    refute(out.first[:tags])
    assert_equal(WH_TAGS, out[1][:tags])
    assert_kind_of(Numeric, out[2][:ts])
  end

  def test_dists_to_wf
    true
  end

  def test_flush_gauges
    assert_nil(wf.flush_gauges([]))

    input = [{ path: 'm1.p', ts: 1548636080, value: 0 },
             { path: 'm1.p', ts: 1548636081, value: 1, tags: WH_TAGS },
             { path: 'm2.p', ts: 1548636081, value: 9 }]

    mocket = Mocket.new
    spy = Spy.on(wf.writer.writer, :write).and_return(mocket)

    out = wf.flush_gauges(input)
    args = spy.calls.first.args.first
    assert_instance_of(Mocket, out)
    assert spy.has_been_called?
    assert_equal(input, args)
    assert(args.any?{ |a| a.key?(:tags) && a[:tags] == WH_TAGS })
    refute(args.all?{ |a| a.key?(:tags) })
    assert_empty(wf.buf[:gauges])
  end

  def test_flush_gauges_fail
    assert_nil(wf.flush_gauges([]))

    input = [{ path: 'm1.p', ts: 1548636080, value: 0 }]

    mocket = BadMocket.new
    spy = Spy.on(wf.writer.writer, :write).and_return(mocket)
    out = wf.flush_gauges(input)
    assert_instance_of(BadMocket, out)
    wf.gauge('m2.p', 9)
    wf.gauge('m3.p', 9)
    assert spy.has_been_called?
    assert_equal(input, spy.calls.first.args.first)
    assert_equal(3, wf.buf[:gauges].size)
    assert_includes(wf.buf[:gauges],
                    { path: 'm1.p', ts: 1548636080, value: 0 })
  end

  def test_flush_counters
    assert_nil(wf.flush_counters([]))

    input = { ['test.counter1', nil]     => 7,
              ['test.counter1', WH_TAGS] => 8,
              ['test.counter2', nil]     => 9 }

    mocket = Mocket.new
    spy = Spy.on(wf.writer.writer, :write).and_return(mocket)

    out = wf.flush_counters(input)
    args = spy.calls.first.args.first

    assert_instance_of(Mocket, out)
    assert spy.has_been_called?
    assert_equal(3, args.size)

    args.each do |a|
      assert_instance_of(Hash, a)
      assert_includes(a.keys, :path)
      assert_includes(a.keys, :ts)
      assert_includes(a.keys, :value)
      assert(a[:path].start_with?(DELTA))
    end

    assert(args.any?{ |a| a.key?(:tags) && a[:tags] == WH_TAGS })
    refute(args.all?{ |a| a.key?(:tags) })
    assert_empty(wf.buf[:counters])
  end

  def test_flush_dists
    assert_nil(wf.flush_dists([]))
  end

  def test_dist_opts
    o = wfd.dist_opts(D_CREDS)
    assert_equal(40000, o[:port])
    assert_equal('wavefront', o[:proxy])
  end
end
# rubocop:enable Style/NumericLiterals
