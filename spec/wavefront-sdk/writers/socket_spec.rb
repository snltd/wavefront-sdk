#!/usr/bin/env ruby

require 'webmock/minitest'
require 'spy/integration'
require 'socket'
require 'logger'
require_relative '../../spec_helper'
require_relative '../../../lib/wavefront-sdk/write'
require_relative '../resources/dummy_points'

# rubocop:disable Style/MutableConstant
WS_CREDS = { proxy: 'wavefront-proxy' }
# rubocop:enable Style/MutableConstant

# It's not straightforward to test the Writer::Socket class on its
# own. It makes far more sense to test the Write interface which
# calls it.
#
class WavefrontWriterSocketTest < MiniTest::Test
  attr_reader :wf, :wf_noop

  def setup
    @wf = Wavefront::Write.new(WS_CREDS, writer: :socket)
    @wf_noop = Wavefront::Write.new(WS_CREDS, writer: :socket, noop: true)
  end

  def test_writer_class
    assert_instance_of(Wavefront::Writer::Socket, wf.writer)
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

  def test_write_array
    mocket = Mocket.new
    Spy.on(TCPSocket, :new).and_return(mocket)
    mocket_spy = Spy.on(mocket, :puts)
    wf.open
    wf.write(POINT_A, false)
    assert mocket_spy.has_been_called?
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
    assert_equal(tcp_spy.calls.first.args, ['wavefront-proxy', 2878])
  end

  def test_noop_open
    tcp_spy = Spy.on(TCPSocket, :new)
    wf_noop.open
    refute tcp_spy.has_been_called?
  end
end
