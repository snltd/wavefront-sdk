#!/usr/bin/env ruby
# frozen_string_literal: true

require_relative '../spec_helper'
require_relative '../test_mixins/general'

# Unit tests for notificant class
#
class WavefrontNotificantTest < WavefrontTestBase
  include WavefrontTest::List
  include WavefrontTest::Delete
  include WavefrontTest::Describe
  include WavefrontTest::Update

  def test_test
    assert_posts("/api/v2/notificant/test/#{id}") { wf.test(id) }
    assert_invalid_id { wf.test(invalid_id) }
  end

  private

  def api_class
    'notificant'
  end

  def id
    '8Bl5l7wxtdGindxk'
  end

  def invalid_id
    '---rubbish---'
  end

  def payload
    JSON.parse(%(
{
  "method": "PAGERDUTY",
  "id": "PE0BEkf4r123yooO",
  "contentType": "",
  "description": "Test target",
  "customerId": "sysdef",
  "title": "Terraform Test Target",
  "recipient": "12345678910111213141516171819202",
  "creatorId": "someone@example.com",
  "updaterId": "someone@example.com",
  "createdEpochMillis": 1604513812010,
  "updatedEpochMillis": 1604513812010,
  "template": "{}",
  "triggers": [
    "ALERT_OPENED",
    "ALERT_RESOLVED"
  ],
  "customHttpHeaders": {},
  "emailSubject": "",
  "isHtmlContent": false
}
    ), symbolize_names: true)
  end
end
