#!/usr/bin/env ruby
# frozen_string_literal: true

require_relative '../../spec_helper'
require_relative '../../../lib/wavefront-sdk/support/mixins'
require 'spy/integration'

# Test SDK mixins
#
class WavefrontMixinsTest < Minitest::Test
  include Wavefront::Mixins

  def test_parse_time
    base_t = Time.now.to_i
    assert_equal(1_469_711_187, parse_time(1_469_711_187))
    assert_equal(1_469_712_336, parse_time('2016-07-28 14:25:36 +0100'))
    assert_kind_of(Numeric, parse_time(Time.now))
    assert_kind_of(Numeric, parse_time(Time.now, true))
    assert parse_time(Time.now) >= base_t
    assert parse_time(Time.now, true) >= base_t * 1000
    assert parse_time(Time.now, true) < base_t * 1001
    assert_kind_of(Numeric, parse_time(Time.now))
    assert_kind_of(Numeric, parse_time(Time.now, true))
    assert_raises(Wavefront::Exception::InvalidTimestamp) do
      parse_time('nonsense')
    end

    trt_spy = Spy.on(self, :relative_time).and_call_through

    parse_time('+5m')
    parse_time('-0.5m')

    assert_equal trt_spy.calls.length, 2
  end

  def test_relative_time
    base = Time.now
    bi = base.to_i
    ms_base = base.to_date
    mbi = ms_base.strftime('%Q').to_i

    assert_equal(bi + 60, relative_time('+60s', false, base))
    assert_equal(bi - 60, relative_time('-60s', false, base))
    assert_equal(bi + 30, relative_time('+.5m', false, base))
    assert_equal(bi - 30, relative_time('-000.50m', false, base))

    assert_equal(mbi + 60_000, relative_time('+60s', true, ms_base))
    assert_equal(mbi - 60_000, relative_time('-60s', true, ms_base))
    assert_equal(mbi + 30_000, relative_time('+.5m', true, ms_base))
    assert_equal(mbi - 30_000, relative_time('-000.50m', true, ms_base))

    assert_raises(Wavefront::Exception::InvalidRelativeTime) do
      relative_time('5m')
    end
  end

  def test_valid_relative_time?
    assert valid_relative_time?('+1h')
    assert valid_relative_time?('+1m')
    assert valid_relative_time?('-1s')
    assert valid_relative_time?('-10d')
    assert valid_relative_time?('+1.3h')
    assert valid_relative_time?('+1h')
    assert valid_relative_time?('-1h')
    assert valid_relative_time?('-1.142w')
    assert valid_relative_time?('+0.002y')
    refute valid_relative_time?('1h')
    refute valid_relative_time?('1m')
    refute valid_relative_time?('-1t')
    refute valid_relative_time?('-dd')
    refute valid_relative_time?('-1.1.1d')
  end

  def test_parse_relative_time
    assert_equal(-5, parse_relative_time('-5s'))
    assert_equal(-5000, parse_relative_time('-5s', true))
    assert_equal(10_000, parse_relative_time('+10000s'))
    assert_equal(-300, parse_relative_time('-5m'))
    assert_equal(-30, parse_relative_time('-.5m'))
    assert_equal(-30, parse_relative_time('-0.5m'))
    assert_equal(300, parse_relative_time('+5m'))
    assert_equal(30, parse_relative_time('+.5m'))
    assert_equal(30, parse_relative_time('+.50m'))
    assert_equal(30_000, parse_relative_time('+.50m', true))
    assert_equal(30, parse_relative_time('+.50m'))
    assert_equal(129_600, parse_relative_time('+1.5d'))
    assert_equal(-129_600, parse_relative_time('-1.5d'))

    ['-1.5p', '1.5m', '+1.3.5s'].each do
      assert_raises Wavefront::Exception::InvalidRelativeTime do |t|
        parse_relative_time(t)
      end
    end
  end

  def test_time_multiplier
    assert_equal(1, time_multiplier(:s))
    assert_equal(1, time_multiplier('s'))
    assert_equal(60, time_multiplier(:m))
    assert_equal(3600, time_multiplier(:h))
    assert_equal(86_400, time_multiplier(:d))
    assert_equal(604_800, time_multiplier(:w))
    assert_equal(31_536_000, time_multiplier(:y))

    assert_raises(Wavefront::Exception::InvalidTimeUnit) do
      time_multiplier(:p)
    end
  end
end
