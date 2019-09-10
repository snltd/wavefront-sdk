#!/usr/bin/env ruby

require_relative '../spec_helper'
require_relative '../test_mixins/general'

# Unit tests for Webhook class
#
class WavefrontWebhookTest < WavefrontTestBase
  include WavefrontTest::Create
  include WavefrontTest::Delete
  include WavefrontTest::Describe
  include WavefrontTest::List
  include WavefrontTest::Update

  private

  def api_class
    'webhook'
  end

  def id
    '9095WaGklE8Gy3M1'
  end

  def invalid_id
    '+-+-+-+'
  end

  def payload
    { description:       'WebHook Description',
      template:          'POST Body -- Mustache syntax',
      title:             'WebHook Title',
      triggers:          %w[ALERT_OPENED],
      recipient:         'http://example.com',
      customHttpHeaders: {},
      contentType:       'text/plain' }
  end
end
