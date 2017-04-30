#!/usr/bin/env ruby

require_relative './spec_helper'

ALERT = '1481553823153'.freeze
ALERT_BODY = {
  name:               'SDK test alert',
  target:             'user@example.com',
  condition:          'ts("app.errors") > 0',
  displayExpression:  'ts("app.errors")',
  minutes:             5,
  resolveAfterMinutes: 5,
  severity:            'INFO',
}.freeze

# Unit tests for Alert class
#
class WavefrontAlertTest < WavefrontTestBase
  def should_fail_tags(method)
    assert_raises(Wavefront::Exception::InvalidAlert) do
      wf.send(method, 'abc', 'tag1')
    end

    assert_raises(Wavefront::Exception::InvalidString) do
      wf.send(method, ALERT, '<!!!>')
    end
  end

  def test_list
    should_work(:list, 10, '?offset=10&limit=100')
  end

  def test_describe
    should_work(:describe, ALERT, ALERT)
    assert_raises(ArgumentError) { wf.describe }
    should_be_invalid(:describe)
  end

  def test_create
    should_work(:create, ALERT_BODY, '', :post, JSON_POST_HEADERS,
                ALERT_BODY.to_json)
    assert_raises(ArgumentError) { wf.create }
    assert_raises(ArgumentError) { wf.create('test') }
  end

  def test_describe_v
    should_work(:describe, [ALERT, 4], "#{ALERT}/history/4")
  end

  def test_delete
    should_work(:delete, ALERT, ALERT, :delete)
    should_be_invalid(:delete)
  end

  def test_history
    should_work(:history, ALERT, "#{ALERT}/history")
    should_be_invalid(:history)
  end

  def test_snooze
    should_work(:snooze, ALERT, ["#{ALERT}/snooze", 3600], :post,
                POST_HEADERS)
    should_be_invalid(:snooze)
  end

  def test_update
    should_work(:update, [ALERT, ALERT_BODY], ALERT, :put,
                JSON_POST_HEADERS, ALERT_BODY.to_json )
    should_be_invalid(:update, ['abcde', ALERT_BODY])
    assert_raises(ArgumentError) { wf.update }
  end

  def test_tags
    should_work(:tags, ALERT, "#{ALERT}/tag")
    should_be_invalid(:tags)
  end

  def test_tag_set
    should_work(:tag_set, [ALERT, 'tag'],
                ["#{ALERT}/tag", ['tag'].to_json], :post, JSON_POST_HEADERS)
    should_work(:tag_set, [ALERT, %w(tag1 tag2)],
                ["#{ALERT}/tag", %w(tag1 tag2).to_json], :post,
                JSON_POST_HEADERS)
    should_fail_tags(:tag_set)
  end

  def test_tag_add
    should_work(:tag_add, [ALERT, 'tagval'],
                ["#{ALERT}/tag/tagval", nil], :put, JSON_POST_HEADERS)
    should_fail_tags(:tag_add)
  end

  def test_tag_delete
    should_work(:tag_delete, [ALERT, 'tagval'], "#{ALERT}/tag/tagval",
                :delete)
    should_fail_tags(:tag_delete)
  end

  def test_undelete
    should_work(:undelete, ALERT, ["#{ALERT}/undelete", nil], :post,
                POST_HEADERS)
    should_be_invalid(:undelete)
  end

  def test_unsnooze
    should_work(:unsnooze, ALERT, ["#{ALERT}/unsnooze", nil], :post,
                POST_HEADERS)
    should_be_invalid(:unsnooze)
  end

  def test_summary
    should_work(:summary, nil, 'summary')
  end
end
