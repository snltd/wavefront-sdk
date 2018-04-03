#!/usr/bin/env ruby

require_relative '../spec_helper'
require_relative '../../lib/wavefront-sdk/mixins'
require 'spy/integration'

# Test SDK mixins
#
class WavefrontMixinsTest < MiniTest::Test
  include Wavefront::Mixins

  # rubocop:disable Lint/UnifiedInteger
  def test_parse_time
    base_t = Time.now.to_i
    assert_equal parse_time(1_469_711_187), 1_469_711_187
    assert_equal parse_time('2016-07-28 14:25:36 +0100'), 1_469_712_336
    assert_instance_of Fixnum, parse_time(Time.now)
    assert_instance_of Fixnum, parse_time(Time.now, true)
    assert parse_time(Time.now) >= base_t
    assert parse_time(Time.now, true) >= base_t * 1000
    assert parse_time(Time.now, true) < base_t * 1001
    assert_instance_of Fixnum, parse_time(Time.now)
    assert_instance_of Fixnum, parse_time(Time.now, true)
    assert_raises(Wavefront::Exception::InvalidTimestamp) do
      parse_time('nonsense')
    end

    trt_spy = Spy.on(self, :relative_time).and_call_through

    parse_time('+5m')
    parse_time('-0.5m')

    assert_equal trt_spy.calls.length, 2
  end
  # rubocop:enable Lint/UnifiedInteger

  def test_relative_time
    base = Time.now
    bi = base.to_i
    ms_base = base.to_date
    mbi = ms_base.strftime('%Q').to_i

    assert_equal relative_time('+60s', false, base), bi + 60
    assert_equal relative_time('-60s', false, base), bi - 60
    assert_equal relative_time('+.5m', false, base), bi + 30
    assert_equal relative_time('-000.50m', false, base), bi - 30

    assert_equal relative_time('+60s', true, ms_base), mbi + 60 * 1000
    assert_equal relative_time('-60s', true, ms_base), mbi - 60 * 1000
    assert_equal relative_time('+.5m', true, ms_base), mbi + 30 * 1000
    assert_equal relative_time('-000.50m', true, ms_base), mbi - 30 * 1000

    assert_raises(Wavefront::Exception::InvalidRelativeTime) do
      relative_time('5m')
    end
  end

  def test_parse_relative_time
    assert_equal parse_relative_time('-5s'), -5
    assert_equal parse_relative_time('-5s', true), -5000
    assert_equal parse_relative_time('+10000s'), 10_000
    assert_equal parse_relative_time('-5m'), -300
    assert_equal parse_relative_time('-.5m'), -30
    assert_equal parse_relative_time('-0.5m'), -30
    assert_equal parse_relative_time('+5m'), 300
    assert_equal parse_relative_time('+.5m'), 30
    assert_equal parse_relative_time('+.50m'), 30
    assert_equal parse_relative_time('+.50m', true), 30 * 1000
    assert_equal parse_relative_time('+.50m'), 30
    assert_equal parse_relative_time('+1.5d'), 60 * 60 * 24 * 1.5
    assert_equal parse_relative_time('-1.5d'), 60 * 60 * 24 * -1.5

    ['-1.5p', '1.5m', '+1.3.5s'].each do
      assert_raises Wavefront::Exception::InvalidRelativeTime do |t|
        parse_relative_time(t)
      end
    end
  end

  def test_time_multiplier
    assert_equal time_multiplier(:s), 1
    assert_equal time_multiplier('s'), 1
    assert_equal time_multiplier(:m), 60
    assert_equal time_multiplier(:h), 60 * 60
    assert_equal time_multiplier(:d), 60 * 60 * 24
    assert_equal time_multiplier(:w), 60 * 60 * 24 * 7
    assert_equal time_multiplier(:y), 60 * 60 * 24 * 365

    assert_raises(Wavefront::Exception::InvalidTimeUnit) do
      time_multiplier(:p)
    end
  end
end
