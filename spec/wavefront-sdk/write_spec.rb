#!/usr/bin/env ruby
# frozen_string_literal: true

require_relative '../spec_helper'
require_relative '../support/mocket'
require_relative '../support/bad_mocket'
require_relative '../../lib/wavefront-sdk/write'
require_relative '../../lib/wavefront-sdk/core/response'
require_relative 'resources/dummy_points'

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
    assert_instance_of(Wavefront::Writer::Proxy, wf.writer)
  end

  def test_composite_response
    bad_status = { result: 'ERROR', message: nil, code: nil }
    bad_response = { sent: 0, rejected: 1, unsent: 0 }
    good_status = { result: 'OK', message: nil, code: nil }
    good_response = { sent: 1, rejected: 0, unsent: 0 }

    bad_resp = Wavefront::Response.new(
      { status: bad_status, response: bad_response }.to_json, nil
    )

    good_resp = Wavefront::Response.new(
      { status: good_status, response: good_response }.to_json, nil
    )

    x = wf.composite_response(Array.new(5).map { good_resp })
    assert x.ok?
    assert_equal('OK', x.status.result)
    assert_equal(5, x.response.sent)
    assert_equal(0, x.response.rejected)
    assert_equal(0, x.response.unsent)

    y = wf.composite_response(Array.new(4).map { good_resp } + [bad_resp])
    refute y.ok?
    assert_equal('ERROR', y.status.result)
    assert_equal(4, y.response.sent)
    assert_equal(1, y.response.rejected)
    assert_equal(0, y.response.unsent)

    z = wf.composite_response(Array.new(5).map { bad_resp })
    refute z.ok?
    assert_equal('ERROR', z.status.result)
    assert_equal(0, z.response.sent)
    assert_equal(5, z.response.rejected)
    assert_equal(0, z.response.unsent)
  end

  def test_write_empty
    assert wf.write([])
  end

  def test_bad_write
    write_method = Spy.on(wf.writer, :write).and_return(BadMocket.new)
    refute wf.write(point_array(19)).ok?
    assert write_method.has_been_called?
    assert_equal(1, write_method.calls.size)
  end

  def test_write_single_chunk
    write_method = Spy.on(wf.writer, :write).and_return(Mocket.new)
    assert wf.write(point_array(19)).ok?
    assert write_method.has_been_called?
    assert_equal(1, write_method.calls.size)
  end

  def test_write_multi_chunk
    write_method = Spy.on(wf.writer, :write).and_return(Mocket.new)
    assert wf.write(point_array(4321))
    assert write_method.has_been_called?
    assert_equal(5, write_method.calls.size)
  end

  # helper to test write chunking
  #
  def point_array(count)
    1.upto(count).map do |i|
      { path: 'dummy.path', value: i, ts: Time.now.to_i - i }
    end
  end

  def test_paths_to_deltas
    x = wf.paths_to_deltas(POINTS.dup)
    assert_equal(x.size, 2)

    x.each do |p|
      assert_instance_of(Hash, p)
      assert(p[:path].start_with?(DELTA))
    end
  end

  def test_point_hash_all_values
    point = POINT.dup

    assert_equal({ path: 'test.metric',
                   value: 123_456,
                   ts: 1_469_987_572,
                   source: 'testhost',
                   tags: 't1="v1" t2="v2"',
                   opttags: nil }, wf.point_hash(point))
  end

  def test_point_hash_missing_timestamp
    point = POINT.dup.tap { |p| p.delete(:ts) }

    assert_equal({ path: 'test.metric',
                   value: 123_456,
                   ts: nil,
                   source: 'testhost',
                   tags: 't1="v1" t2="v2"',
                   opttags: nil }, wf.point_hash(point))
  end

  def test_point_hash_missing_tags
    point = POINT.dup.tap { |p| p.delete(:tags) }

    assert_equal({ path: 'test.metric',
                   value: 123_456,
                   ts: 1_469_987_572,
                   source: 'testhost',
                   tags: nil,
                   opttags: nil }, wf.point_hash(point))
  end

  def test_hash_to_wf
    assert_equal(wf.hash_to_wf(POINT),
                 'test.metric 123456 1469987572 ' \
                 'source=testhost t1="v1" t2="v2"')
  end

  def test_hash_to_wf_tags_via_options
    assert_equal(wf_tags.hash_to_wf(POINT),
                 'test.metric 123456 1469987572 ' \
                 'source=testhost t1="v1" t2="v2" ' \
                 'gt1="gv1" gt2="gv2"')
  end

  def test_hash_to_wf_missing_timestamp
    point = POINT.dup.tap { |p| p.delete(:ts) }
    assert_equal(wf.hash_to_wf(point),
                 'test.metric 123456 source=testhost t1="v1" t2="v2"')
  end

  def test_hash_to_wf_missing_tags
    point = POINT.dup.tap { |p| p.delete(:tags) }
    assert_equal(wf.hash_to_wf(point),
                 'test.metric 123456 1469987572 source=testhost')
  end

  def test_hash_to_wf_missing_value
    point = POINT.dup.tap { |p| p.delete(:value) }
    assert_raises(Wavefront::Exception::InvalidMetricValue) do
      wf.hash_to_wf(point)
    end
  end

  def test_hash_to_wf_missing_path
    point = POINT.dup.tap { |p| p.delete(:path) }
    assert_raises(Wavefront::Exception::InvalidMetricName) do
      wf.hash_to_wf(point)
    end
  end
end
