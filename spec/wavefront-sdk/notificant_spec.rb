#!/usr/bin/env ruby

require_relative '../spec_helper'

NOTIFICANT = '8Bl5l7wxtdGindxk'.freeze

# Unit tests for notificant class
#
class WavefrontNotificantTest < WavefrontTestBase
  def test_list
    should_work(:list, 10, '?offset=10&limit=100')
  end

  def test_describe
    should_work(:describe, NOTIFICANT, NOTIFICANT)
    should_be_invalid(:describe)
    assert_raises(ArgumentError) { wf.describe }
  end

  def test_delete
    should_work(:delete, NOTIFICANT, NOTIFICANT, :delete)
    should_be_invalid('delete')
  end

  def test_test
    should_work(:test, NOTIFICANT, ["test/#{NOTIFICANT}", nil],
                :post, POST_HEADERS)
    should_be_invalid('test')
  end
end
