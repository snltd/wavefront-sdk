#!/usr/bin/env ruby
# frozen_string_literal: true

require_relative '../../spec_helper'
require_relative '../../../lib/wavefront-sdk/support/parse_time'

TSS = 1_517_151_869
TSM = 1_517_151_869_523

# Test parse_time class
#
class WavefrontParseTimeTest < Minitest::Test
  attr_reader :pts, :ptm

  def setup
    @pts = Wavefront::ParseTime.new(TSS, false)
    @ptm = Wavefront::ParseTime.new(TSM, true)
  end

  def test_parse_time_fixnum
    assert_equal(TSS, pts.parse_time_fixnum)
    assert_equal(TSM, ptm.parse_time_fixnum)
  end

  def test_parse_time_integer
    assert_equal(TSS, pts.parse_time_integer)
    assert_equal(TSM, ptm.parse_time_integer)
  end

  def test_parse_time_string
    ptss = Wavefront::ParseTime.new(TSS.to_s, false)
    ptms = Wavefront::ParseTime.new(TSM.to_s, true)
    assert_kind_of(Numeric, ptss.parse_time_string)
    assert_kind_of(Numeric, ptms.parse_time_string)
    assert_equal(TSS, ptss.parse_time_string)
    assert_equal(TSM, ptms.parse_time_string)
    assert_kind_of(Numeric, ptss.parse!)
    assert_kind_of(Numeric, ptms.parse!)
  end

  def test_parse_time_time
    ptst = Wavefront::ParseTime.new(Time.at(TSS), false)
    ptmt = Wavefront::ParseTime.new(DateTime.strptime(TSM.to_s,
                                                      '%Q').to_time, true)
    assert_equal(TSS, ptst.parse_time_time)
    assert_equal(TSM, ptmt.parse_time_time)
    assert_kind_of(Numeric, ptst.parse!)
    assert_kind_of(Numeric, ptmt.parse!)
  end

  def test_parse_time_datetime
    ptsd = Wavefront::ParseTime.new(Time.at(TSS).to_datetime, false)
    ptmd = Wavefront::ParseTime.new(DateTime.strptime(TSM.to_s, '%Q'), true)
    assert_kind_of(Numeric, ptsd.parse_time_datetime, TSS)
    assert_kind_of(Numeric, ptmd.parse_time_datetime, TSM)
    assert_equal(TSS, ptsd.parse_time_datetime)
    assert_equal(TSM, ptmd.parse_time_datetime)
    assert_kind_of(Numeric, ptsd.parse!)
    assert_kind_of(Numeric, ptmd.parse!)
  end

  def test_parse!
    assert_kind_of(Numeric, pts.parse!)
    assert_kind_of(Numeric, ptm.parse!)
  end
end
