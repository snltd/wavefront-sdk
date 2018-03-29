#!/usr/bin/env ruby

require_relative '../spec_helper'
require_relative '../../lib/wavefront-sdk/parse_time'

TSS = 1517151869
TSM = 1517151869523

# Test parse_time class
#
class WavefrontParseTimeTest < MiniTest::Test
  attr_reader :pts, :ptm

  def setup
    @pts = Wavefront::ParseTime.new(TSS, false)
    @ptm = Wavefront::ParseTime.new(TSM, true)
  end

  def test_parse_time_Fixnum
    assert_equal(pts.parse_time_Fixnum, TSS)
    assert_equal(ptm.parse_time_Fixnum, TSM)
  end

  def test_parse_time_Integer
    assert_equal(pts.parse_time_Integer, TSS)
    assert_equal(ptm.parse_time_Integer, TSM)
  end

  def test_parse_time_String
    ptss = Wavefront::ParseTime.new(TSS.to_s, false)
    ptms = Wavefront::ParseTime.new(TSM.to_s, true)
    assert_instance_of(Fixnum, ptss.parse_time_String, TSS)
    assert_instance_of(Fixnum, ptms.parse_time_String, TSM)
    assert_equal(ptss.parse_time_String, TSS)
    assert_equal(ptms.parse_time_String, TSM)
    assert_instance_of(Fixnum, ptss.parse!)
    assert_instance_of(Fixnum, ptms.parse!)
  end

  def test_parse_time_Time
    ptst = Wavefront::ParseTime.new(Time.at(TSS), false)
    ptmt = Wavefront::ParseTime.new(DateTime.strptime(TSM.to_s,
                                                      '%Q').to_time, true)
    assert_equal(ptst.parse_time_Time, TSS)
    assert_equal(ptmt.parse_time_Time, TSM)
    assert_instance_of(Fixnum, ptst.parse!)
    assert_instance_of(Fixnum, ptmt.parse!)
  end

  def test_parse_time_DateTime
    ptsd = Wavefront::ParseTime.new(Time.at(TSS).to_datetime, false)
    ptmd = Wavefront::ParseTime.new(DateTime.strptime(TSM.to_s, '%Q'), true)
    assert_instance_of(Fixnum, ptsd.parse_time_DateTime, TSS)
    assert_instance_of(Fixnum, ptmd.parse_time_DateTime, TSM)
    assert_equal(ptsd.parse_time_DateTime, TSS)
    assert_equal(ptmd.parse_time_DateTime, TSM)
    assert_instance_of(Fixnum, ptsd.parse!)
    assert_instance_of(Fixnum, ptmd.parse!)
  end

  def test_parse!
    assert_instance_of(Fixnum, pts.parse!)
    assert_instance_of(Fixnum, ptm.parse!)
  end
end
