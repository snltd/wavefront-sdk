#!/usr/bin/env ruby

require_relative '../../spec_helper'
require_relative '../../../lib/wavefront-sdk/stdlib/array'

# Test extensions to stdlib's Array class
#
class ArrayTest < MiniTest::Test
  def test_uri_concat
    assert_equal %w[a b].uri_concat, 'a/b'
    assert_equal ['', 'a', 'b'].uri_concat, '/a/b'
    assert_equal %w[a /b].uri_concat, 'a/b'
    assert_equal ['', 'a', 'b/'].uri_concat, '/a/b'
    assert_equal %w[/a /b/ /c].uri_concat, '/a/b/c'
    assert_equal ['/a', '/b c'].uri_concat, '/a/b c'
  end
end
