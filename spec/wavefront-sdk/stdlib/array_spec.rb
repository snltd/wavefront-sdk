#!/usr/bin/env ruby
# frozen_string_literal: true

require_relative '../../spec_helper'
require_relative '../../../lib/wavefront-sdk/stdlib/array'

# Test extensions to stdlib's Array class
#
class ArrayTest < MiniTest::Test
  def test_uri_concat
    assert_equal('a/b', %w[a b].uri_concat)
    assert_equal('/a/b', ['', 'a', 'b'].uri_concat)
    assert_equal('a/b', %w[a /b].uri_concat)
    assert_equal('/a/b', ['', 'a', 'b/'].uri_concat)
    assert_equal('/a/b/c', %w[/a /b/ /c].uri_concat)
    assert_equal('/a/b c', ['/a', '/b c'].uri_concat)
  end
end
