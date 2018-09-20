#!/usr/bin/env ruby

require_relative '../../../lib/wavefront-sdk/core/write'
require_relative '../../spec_helper'
require_relative '../resources/dummy_points'

# rubocop:disable Style/MutableConstant
WBWT_CREDS = { endpoint: 'stub.wavefront.com', token: 'tkn' }
# rubocop:enable Style/MutableConstant

# Test methods common to 'write' and 'report'
#
class WavefrontCoreWriteTest < MiniTest::Test
  attr_reader :wf, :wf_tags

  def setup
    @wf = Wavefront::CoreWrite.new(WBWT_CREDS)
    @wf_tags = Wavefront::CoreWrite.new(WBWT_CREDS, tags: TAGS)
  end

  def test_summary_string
    assert_equal('OK', wf.summary_string(unsent: 0, rejected: 0))
    assert_equal('ERROR', wf.summary_string(unsent: 0, rejected: 1))
    assert_equal('ERROR', wf.summary_string(unsent: 1, rejected: 0))
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
end
