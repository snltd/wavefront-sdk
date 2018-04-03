#!/usr/bin/env ruby

require_relative '../../lib/wavefront-sdk/write.rb'
require 'minitest/autorun'
require 'webmock/minitest'
require 'spy'
require 'spy/integration'
require 'socket'

W_CREDS = { proxy: 'wavefront', port: 2878 }.freeze

TAGS = { gt1: 'gv1', gt2: 'gv2' }.freeze

POINT =  { path:   'test.metric',
           value:  123_456,
           ts:     1_469_987_572,
           source: 'testhost',
           tags:   { t1: 'v1', t2: 'v2' } }.freeze

POINT_L = 'test.metric 123456 1469987572 source=testhost t1="v1" t2="v2"'.freeze

POINT_A = [
  POINT, POINT.dup.update(ts: 1_469_987_588, value: 54_321)
].freeze

POINTS = [POINT.dup,
          { path:   'test.other_metric',
            value:  89,
            ts:     1_469_987_572,
            source: 'otherhost' }].freeze

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
    assert_equal(wf.summary, sent: 0, rejected: 0, unsent: 0)
  end

  def test_write_openclose
    mocket = Mocket.new
    Spy.on(TCPSocket, :new).and_return(mocket)
    mocket_spy = Spy.on(mocket, :puts)
    wf.write(POINT)
    assert mocket_spy.has_been_called?
  end

  def test_write_noop
    mocket = Mocket.new
    Spy.on(TCPSocket, :new).and_return(mocket)
    mocket_spy = Spy.on(mocket, :puts)
    wf_noop.open
    wf_noop.write(POINT, false)
    refute mocket_spy.has_been_called?
  end

  def test_write_noop_openclose
    mocket = Mocket.new
    Spy.on(TCPSocket, :new).and_return(mocket)
    mocket_spy = Spy.on(mocket, :puts)
    wf_noop.write(POINT)
    refute mocket_spy.has_been_called?
  end

  def test_write
    mocket = Mocket.new
    Spy.on(TCPSocket, :new).and_return(mocket)
    mocket_spy = Spy.on(mocket, :puts)
    wf.open
    wf.write(POINT, false)
    assert mocket_spy.has_been_called?
  end

  def test_prepped_points
    assert_equal wf.prepped_points(%w[p1 p2 p3 p4]), %w[p1 p2 p3 p4]
    assert_equal wf.prepped_points([%w[p1 p2 p3 p4]]), %w[p1 p2 p3 p4]
    assert_equal wf.prepped_points('p1'), %w[p1]
    assert_equal wf.prepped_points(
      [{ path: 'p1' }, { path: 'p2' }, { path: 'p3' }], 'prefix'
    ),
                 [{ path: 'prefix.p1' }, { path: 'prefix.p2' },
                  { path: 'prefix.p3' }]

    assert_equal wf.prepped_points({ path: 'p1' }, 'prefix'),
                 [{ path: 'prefix.p1' }]
  end

  def test_write_array
    mocket = Mocket.new
    Spy.on(TCPSocket, :new).and_return(mocket)
    mocket_spy = Spy.on(mocket, :puts)
    wf.open
    wf.write(POINT_A, false)
    assert mocket_spy.has_been_called?
  end

  def test_paths_to_deltas
    x = wf.paths_to_deltas(POINTS.dup)
    assert_equal(x.size, 2)

    x.each do |p|
      assert_instance_of(Hash, p)
      assert(p[:path].start_with?(DELTA))
    end
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

  def test_to_wf_tag
    assert_equal({}.to_wf_tag, '')
    assert_equal(TAGS.to_wf_tag, 'gt1="gv1" gt2="gv2"')
  end

  def test_send_point
    mocket = Mocket.new
    Spy.on(TCPSocket, :new).and_return(mocket)
    mocket_spy = Spy.on(mocket, :puts)
    wf.open
    wf.send_point(POINT_L)
    assert mocket_spy.has_been_called_with?(POINT_L)
  end

  def test_noop_send_point
    mocket = Mocket.new
    Spy.on(TCPSocket, :new).and_return(mocket)
    mocket_spy = Spy.on(mocket, :puts)
    wf_noop.open
    wf_noop.send_point(POINT_L)
    refute mocket_spy.has_been_called?
  end

  def test_open
    tcp_spy = Spy.on(TCPSocket, :new)
    wf.open
    assert tcp_spy.has_been_called?
    assert_equal(tcp_spy.calls.first.args, ['wavefront', 2878])
  end

  def test_noop_open
    tcp_spy = Spy.on(TCPSocket, :new)
    wf_noop.open
    refute tcp_spy.has_been_called?
  end
end

# A mock socket
#
class Mocket
  def puts(socket); end

  def close; end
end
