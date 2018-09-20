#!/usr/bin/env ruby

require_relative '../../spec_helper'
require_relative '../../../lib/wavefront-sdk/stdlib/string'

# Test extensions to stdlib's String class
#
class StringTest < MiniTest::Test
  def test_tagescape
    assert_equal('value', 'value'.tagescape)
    assert_equal('two words', 'two words'.tagescape)
    assert_equal('say \"hello\"', 'say "hello"'.tagescape)
    assert_equal('\"\"\"\"', '""""'.tagescape)
  end
end
