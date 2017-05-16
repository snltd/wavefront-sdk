#!/usr/bin/env ruby

require_relative '../spec_helper'

WINDOW = '1493324005091'.freeze
WINDOW_BODY = {
  reason:   'testing SDK',
  title:    'test window',
  start:    Time.now.to_i,
  end:      Time.now.to_i + 600,
  tags:     %w(testtag1 testtag2),
  hostTags: %w(hosttag1 hosttag2)
}.freeze

# Unit tests for MaintenanceWindow class
#
class WavefrontMaintenanceWindowTest < WavefrontTestBase
  def test_list
    should_work(:list, 10, '?offset=10&limit=100')
    should_work(:list, [20, 30], '?offset=20&limit=30')
  end

  def test_describe
    should_work(:describe, WINDOW, WINDOW)
    should_be_invalid(:describe, 'abcdefg')
    assert_raises(ArgumentError) { wf.describe }
  end

  def test_create
    should_work(:create, WINDOW_BODY, '', :post,
                JSON_POST_HEADERS, WINDOW_BODY.to_json)
    assert_raises(ArgumentError) { wf.create }
    assert_raises(ArgumentError) { wf.create('test') }
  end

  def test_delete
    should_work(:delete, WINDOW, WINDOW, :delete)
    should_be_invalid(:delete, 'abcdefg')
    assert_raises(ArgumentError) { wf.delete }
  end

  def test_update
    should_work(:update, [WINDOW, WINDOW_BODY], WINDOW, :put,
                JSON_POST_HEADERS, WINDOW_BODY.to_json)
    should_be_invalid(:update, ['abcde', WINDOW_BODY])
    assert_raises(ArgumentError) { wf.update }
  end
end
