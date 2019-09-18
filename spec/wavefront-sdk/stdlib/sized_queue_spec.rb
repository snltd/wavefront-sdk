#!/usr/bin/env ruby
# frozen_string_literal: true

require 'minitest/autorun'
require_relative '../../../lib/wavefront-sdk/stdlib/sized_queue'

class SizedQueueTest < MiniTest::Test
  def test_to_a
    q = SizedQueue.new(6)
    1.upto(6) { |i| q.<< i }
    assert_equal([1, 2, 3, 4, 5, 6], q.to_a)
  end
end
