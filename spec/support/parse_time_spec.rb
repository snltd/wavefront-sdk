#!/usr/bin/env ruby

require_relative '../spec_helper'
require_relative '../../lib/support/parse_time'

# rubocop:disable Style/NumericLiterals
TSS = 1517151869
TSM = 1517151869523
# rubocop:enable Style/NumericLiterals

# Test parse_time class. Rubocop gets in the way a bit here.
#
# rubocop:disable Lint/UnifiedInteger
# rubocop:disable Style/DateTime
class WavefrontParseTimeTest < MiniTest::Test
  attr_reader :pts, :ptm

  def setup
    @pts = Wavefront::ParseTime.new(TSS, false)
    @ptm = Wavefront::ParseTime.new(TSM, true)
  end

  def test_parse_time_fixnum
    assert_equal(pts.parse_time_fixnum, TSS)
    assert_equal(ptm.parse_time_fixnum, TSM)
  end

  def test_parse_time_integer
    assert_equal(pts.parse_time_integer, TSS)
    assert_equal(ptm.parse_time_integer, TSM)
  end

  def test_parse_time_string
    ptss = Wavefront::ParseTime.new(TSS.to_s, false)
    ptms = Wavefront::ParseTime.new(TSM.to_s, true)
    assert_instance_of(Fixnum, ptss.parse_time_string, TSS)
    assert_instance_of(Fixnum, ptms.parse_time_string, TSM)
    assert_equal(ptss.parse_time_string, TSS)
    assert_equal(ptms.parse_time_string, TSM)
    assert_instance_of(Fixnum, ptss.parse!)
    assert_instance_of(Fixnum, ptms.parse!)
  end

  def test_parse_time_time
    ptst = Wavefront::ParseTime.new(Time.at(TSS), false)
    ptmt = Wavefront::ParseTime.new(DateTime.strptime(TSM.to_s,
                                                      '%Q').to_time, true)
    assert_equal(ptst.parse_time_time, TSS)
    assert_equal(ptmt.parse_time_time, TSM)
    assert_instance_of(Fixnum, ptst.parse!)
    assert_instance_of(Fixnum, ptmt.parse!)
  end

  def test_parse_time_datetime
    ptsd = Wavefront::ParseTime.new(Time.at(TSS).to_datetime, false)
    ptmd = Wavefront::ParseTime.new(DateTime.strptime(TSM.to_s, '%Q'), true)
    assert_instance_of(Fixnum, ptsd.parse_time_datetime, TSS)
    assert_instance_of(Fixnum, ptmd.parse_time_datetime, TSM)
    assert_equal(ptsd.parse_time_datetime, TSS)
    assert_equal(ptmd.parse_time_datetime, TSM)
    assert_instance_of(Fixnum, ptsd.parse!)
    assert_instance_of(Fixnum, ptmd.parse!)
  end

  def test_parse!
    assert_instance_of(Fixnum, pts.parse!)
    assert_instance_of(Fixnum, ptm.parse!)
  end
end
# rubocop:enable Lint/UnifiedInteger
# rubocop:enable Style/DateTime
