#!/usr/bin/env ruby
# frozen_string_literal: true

require_relative '../../spec_helper'
require_relative '../../../lib/wavefront-sdk/stdlib/time'

# Test extensions to stdlib's Time class
#
class TimeTest < MiniTest::Test
  def test_to_ms
    assert_kind_of(Numeric, Time.now.to_ms)
    assert_equal(154_489_352_000, Time.at(154_489_352).to_ms)
  end
end
