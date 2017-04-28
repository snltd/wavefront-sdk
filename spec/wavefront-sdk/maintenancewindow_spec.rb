#!/usr/bin/env ruby

require_relative './spec_helper'

WINDOW_BODY = {
  reason:   'testing SDK',
  title:    'test window',
  start:    Time.now.to_i,
  end:      Time.now.to_i + 600,
  tags:     ['testtag1', 'testtag2'],
  hostTags: ['hosttag1', 'hosttag2'],
}.freeze

# Unit tests for MaintenanceWindow class
#
class WavefrontMaintenanceWindowTest < WavefrontTestBase
  def test_list
    should_work('list', 10, '?offset=10&limit=100')
    should_work('list', [20, 30], '?offset=20&limit=30')
  end

  def test_describe
    should_work('describe', WINDOW, WINDOW)
    should_be_invalid('describe', 'abcdefg')
    assert_raises(ArgumentError) { wf.describe }
  end

  def test_create
    body_test(hash:     WINDOW_BODY.dup,
              required: [:reason, :title, :start, :end],
              optional: [:tags, :hostTags],
              invalid:
              [[Wavefront::Exception::InvalidTimestamp, [:start, :end]],
               [Wavefront::Exception::InvalidTag, [:tags, :hostTags]]
    ])
  end

  def test_delete
    should_work('delete', WINDOW, WINDOW, :delete)
    should_be_invalid('delete', 'abcdefg')
    assert_raises(ArgumentError) { wf.delete }
  end

=begin
  def test_update
    headers ={'Content-Type': 'application/json',
              'Accept': 'application/json'}

    should_work('update', [WINDOW_BODY],
                WINDOW, :put, headers,
                WINDOW_BODY.to_json)

    should_work('update', [WINDOW_BODY_2],
                WINDOW, :put, headers,
                WINDOW_BODY_2.to_json )

    should_work('update', [WINDOW_BODY_3],
                WINDOW, :put, headers,
                WINDOW_BODY_3.to_json )

    should_be_invalid('update', ['abcde', WINDOW_BODY])
    assert_raises(ArgumentError) { wf.update }
    assert_raises(ArgumentError) { wf.update(WINDOW) }
    assert_raises(Wavefront::Exception::InvalidLinkTemplate) {
      wf.update(WINDOW, { template: 'invalid' }) }
  end
=end
end
