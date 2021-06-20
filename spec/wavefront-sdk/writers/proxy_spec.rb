#!/usr/bin/env ruby
# frozen_string_literal: true

require 'webmock/minitest'
require 'spy'
require 'spy/integration'
require 'socket'
require 'logger'
require_relative '../resources/dummy_points'
require_relative '../../spec_helper'
require_relative '../../../lib/wavefront-sdk/write'
require_relative '../../../spec/support/mocket'

WS_CREDS = { proxy: 'wavefront-proxy' }.freeze

# The Proxy class writes to a proxy TCP socket
#
class WavefrontWriterSocketTest < MiniTest::Test
  attr_reader :wf, :wf_noop

  def setup
    @wf = Wavefront::Write.new(WS_CREDS, writer: :proxy)
    @wf_noop = Wavefront::Write.new(WS_CREDS, writer: :proxy, noop: true)
  end

  def test_writer_class
    assert_instance_of(Wavefront::Writer::Proxy, wf.writer)
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
    assert_equal(['wavefront-proxy', 2878], tcp_spy.calls.first.args)
  end

  def test_noop_open
    tcp_spy = Spy.on(TCPSocket, :new)
    log_spy = Spy.on(wf_noop.logger, :log)
    wf_noop.open
    refute tcp_spy.has_been_called?
    assert_equal(['No-op requested. Not opening connection to proxy.'],
                 log_spy.calls.last.args)
    assert_equal(1, log_spy.calls.size)
  end

  def test_noop_close
    tcp_spy = Spy.on(TCPSocket, :new)
    log_spy = Spy.on(wf_noop.logger, :log)
    wf_noop.close
    refute tcp_spy.has_been_called?
    refute log_spy.has_been_called?
  end

  def test_validate_credentials
    assert(Wavefront::Write.new(WS_CREDS, writer: :proxy))

    assert_instance_of(Wavefront::Write,
                       Wavefront::Write.new(WS_CREDS, writer: :proxy))

    assert_raises(Wavefront::Exception::CredentialError) do
      Wavefront::Write.new({}, writer: :proxy)
    end

    assert_raises(Wavefront::Exception::CredentialError) do
      Wavefront::Write.new({ endpoint: 'wavefront.com' }, writer: :proxy)
    end

    assert_raises(Wavefront::Exception::CredentialError) do
      Wavefront::Write.new({ token: 'abcdef' }, writer: :proxy)
    end

    assert_raises(Wavefront::Exception::CredentialError) do
      Wavefront::Write.new({ proxy: nil }, writer: :proxy)
    end
  end
end
