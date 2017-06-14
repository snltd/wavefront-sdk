#!/usr/bin/env ruby

require_relative '../spec_helper'

WEBHOOK = '9095WaGklE8Gy3M1'.freeze

WEBHOOK_BODY = {
  description:       'WebHook Description',
  template:          'POST Body -- Mustache syntax',
  title:             'WebHook Title',
  triggers:          %w(ALERT_OPENED),
  recipient:         'http://example.com',
  customHttpHeaders: {},
  contentType:       'text/plain'
}.freeze

# Unit tests for Webhook class
#
class WavefrontWebhookTest < WavefrontTestBase
  def test_list
    should_work(:list, 10, '?offset=10&limit=100')
    should_work(:list, [20, 30], '?offset=20&limit=30')
  end

  def test_describe
    should_work(:describe, WEBHOOK, WEBHOOK)
    should_be_invalid(:describe, 'abcdefg')
    assert_raises(ArgumentError) { wf.describe }
  end

  def test_create
    should_work(:create, WEBHOOK_BODY, '', :post,
                JSON_POST_HEADERS, WEBHOOK_BODY.to_json)
    assert_raises(ArgumentError) { wf.create }
    assert_raises(ArgumentError) { wf.create('test') }
  end

  def test_delete
    should_work(:delete, WEBHOOK, WEBHOOK, :delete)
    should_be_invalid(:delete, 'abcdefg')
    assert_raises(ArgumentError) { wf.delete }
  end

  def test_update
    should_work(:update, [WEBHOOK, WEBHOOK_BODY, false], WEBHOOK, :put,
                JSON_POST_HEADERS, WEBHOOK_BODY.to_json)
    should_be_invalid(:update, ['abcde', WEBHOOK_BODY])
    assert_raises(ArgumentError) { wf.update }
  end
end
