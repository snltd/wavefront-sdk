#!/usr/bin/env ruby

require_relative '../spec_helper'
require_relative '../../lib/wavefront-sdk/mixins'

# Test SDK mixins
#
class WavefrontMixinsTest < MiniTest::Test
  include Wavefront::Mixins

  def test_parse_time
    base_t = Time.now.to_i
    assert_equal parse_time(1_469_711_187), 1_469_711_187
    assert_equal parse_time('2016-07-28 14:25:36 +0100'), 1_469_712_336
    assert_equal parse_time('2016-07-28'), 1_469_664_000
    assert_instance_of Fixnum, parse_time(Time.now)
    assert_instance_of Fixnum, parse_time(Time.now, true)
    assert parse_time(Time.now) >= base_t
    assert parse_time(Time.now, true) >= base_t * 1000
    assert parse_time(Time.now, true) < base_t * 1001
    assert_instance_of Fixnum, parse_time(DateTime.now)
    assert_instance_of Fixnum, parse_time(DateTime.now, true)
    assert_raises(Wavefront::Exception::InvalidTimestamp) do
      parse_time('nonsense')
    end
  end
end
