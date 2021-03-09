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

UNIX_SOCK = '/tmp/testsock'

WU_CREDS = { socket: UNIX_SOCK }.freeze

# Test UNIX Datagram socket writing
#
class WavefrontWriterUnixTest < MiniTest::Test
  attr_reader :wf, :wf_noop

  def setup
    @wf = Wavefront::Write.new(WU_CREDS, writer: :socket)
    @wf_noop = Wavefront::Write.new(WU_CREDS, writer: :socket, noop: true)
  end

  def test_writer_class
    assert_instance_of(Wavefront::Writer::Socket, wf.writer)
  end

  def test_write_openclose
    mocket = Mocket.new
    Spy.on(UNIXSocket, :new).and_return(mocket)
    mocket_spy = Spy.on(mocket, :write)
    wf.write(POINT)
    assert mocket_spy.has_been_called?
  end

  def test_write_noop
    mocket = Mocket.new
    Spy.on(UNIXSocket, :new).and_return(mocket)
    mocket_spy = Spy.on(mocket, :write)
    wf_noop.open
    wf_noop.write(POINT, false)
    refute mocket_spy.has_been_called?
  end

  def test_write_noop_openclose
    mocket = Mocket.new
    Spy.on(UNIXSocket, :new).and_return(mocket)
    mocket_spy = Spy.on(mocket, :write)
    wf_noop.write(POINT)
    refute mocket_spy.has_been_called?
  end

  def test_write
    mocket = Mocket.new
    Spy.on(UNIXSocket, :new).and_return(mocket)
    mocket_spy = Spy.on(mocket, :write)
    wf.open
    wf.write(POINT, false)
    assert mocket_spy.has_been_called?
  end

  def test_write_array
    mocket = Mocket.new
    Spy.on(UNIXSocket, :new).and_return(mocket)
    mocket_spy = Spy.on(mocket, :write)
    wf.open
    wf.write(POINT_A, false)
    assert mocket_spy.has_been_called?
  end

  def test_noop_send_point
    mocket = Mocket.new
    Spy.on(UNIXSocket, :new).and_return(mocket)
    mocket_spy = Spy.on(mocket, :write)
    wf_noop.open
    wf_noop.send_point(POINT_L)
    refute mocket_spy.has_been_called?
  end

  def test_open
    tcp_spy = Spy.on(UNIXSocket, :new)
    wf.open
    assert tcp_spy.has_been_called?
    assert_equal([UNIX_SOCK], tcp_spy.calls.first.args)
  end

  def test_noop_open
    tcp_spy = Spy.on(UNIXSocket, :new)
    log_spy = Spy.on(wf_noop.logger, :log)
    wf_noop.open
    refute tcp_spy.has_been_called?
    assert_equal(['No-op requested. Not opening socket connection.'],
                 log_spy.calls.last.args)
    assert_equal(1, log_spy.calls.size)
  end

  def test_noop_close
    tcp_spy = Spy.on(UNIXSocket, :new)
    log_spy = Spy.on(wf_noop.logger, :log)
    wf_noop.close
    refute tcp_spy.has_been_called?
    refute log_spy.has_been_called?
  end

  def test_validate_credentials
    assert(Wavefront::Write.new(WU_CREDS, writer: :socket))

    assert_instance_of(Wavefront::Write,
                       Wavefront::Write.new(WU_CREDS, writer: :socket))

    assert_raises(Wavefront::Exception::CredentialError) do
      Wavefront::Write.new({}, writer: :socket)
    end

    assert_raises(Wavefront::Exception::CredentialError) do
      Wavefront::Write.new({ endpoint: 'wavefront.com' }, writer: :socket)
    end

    assert_raises(Wavefront::Exception::CredentialError) do
      Wavefront::Write.new({ token: 'abcdef' }, writer: :socket)
    end

    assert_raises(Wavefront::Exception::CredentialError) do
      Wavefront::Write.new({ proxy: nil }, writer: :socket)
    end
  end
end
