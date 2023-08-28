#!/usr/bin/env ruby
# frozen_string_literal: true

require_relative '../spec_helper'
require_relative '../test_mixins/acl'
require_relative '../test_mixins/tag'
require_relative '../test_mixins/general'

# Unit tests for Alert class
#
class WavefrontAlertTest < WavefrontTestBase
  include WavefrontTest::Acl
  include WavefrontTest::Clone
  include WavefrontTest::Create
  include WavefrontTest::DeleteUndelete
  include WavefrontTest::Describe
  include WavefrontTest::History
  include WavefrontTest::InstallUninstall
  include WavefrontTest::List
  include WavefrontTest::Tag
  include WavefrontTest::Update

  def test_snooze
    assert_posts("/api/v2/alert/#{id}/snooze") { wf.snooze(id) }

    assert_posts("/api/v2/alert/#{id}/snooze?seconds=3600") do
      wf.snooze(id, 3600)
    end

    assert_invalid_id { wf.snooze(invalid_id) }
  end

  def test_unsnooze
    assert_posts("/api/v2/alert/#{id}/unsnooze") { wf.unsnooze(id) }
    assert_invalid_id { wf.unsnooze(invalid_id) }
  end

  def test_check_query
    query = {
      inputQuery: 'string',
      translatedInput: 'sum(http_requests_total{method="GET"})',
      queryType: 'PromQL'
    }
    assert_posts('/api/v2/alert/checkQuery', query.to_json) do
      wf.check_query(query)
    end
  end

  def test_preview
    assert_posts('/api/v2/alert/preview', payload.to_json) do
      wf.preview(payload)
    end
  end

  def test_summary
    assert_gets('/api/v2/alert/summary') { wf.summary }
  end

  def test_alerts_in_state
    assert_posts('/api/v2/search/alert', search_payload('state')) do
      wf.alerts_in_state('state')
    end
  end

  def test_firing
    assert_posts('/api/v2/search/alert', search_payload('firing')) do
      wf.firing
    end
  end

  def test_active
    assert_posts('/api/v2/search/alert', search_payload('firing')) do
      wf.active
    end
  end

  def test_affected_by_maintenance
    assert_posts('/api/v2/search/alert',
                 search_payload('in_maintenance')) do
      wf.affected_by_maintenance
    end
  end

  def test_invalid
    assert_posts('/api/v2/search/alert', search_payload('invalid')) do
      wf.invalid
    end
  end

  def test_none
    assert_posts('/api/v2/search/alert', search_payload('none')) do
      wf.none
    end
  end

  def test_checking
    assert_posts('/api/v2/search/alert', search_payload('checking')) do
      wf.checking
    end
  end

  def test_trash
    assert_posts('/api/v2/search/alert', search_payload('trash')) do
      wf.trash
    end
  end

  def test_no_data
    assert_posts('/api/v2/search/alert', search_payload('no_data')) do
      wf.no_data
    end
  end

  def test_snoozed
    assert_posts('/api/v2/search/alert', search_payload('snoozed')) do
      wf.snoozed
    end
  end

  # Not a full test, because it's a recursive API call. Just test
  # the first API call is made correctly.
  #
  def test_all
    assert_gets("/api/v2/#{api_class}?offset=0&limit=999") { wf.all }
  end

  private

  # used by the things we #include
  #
  def api_class
    'alert'
  end

  def id
    '1481553823153'
  end

  def invalid_id
    'invalid_alert'
  end

  def payload
    { name: 'SDK test alert',
      target: 'user@example.com',
      condition: 'ts("app.errors") > 0',
      displayExpression: 'ts("app.errors")',
      minutes: 5,
      resolveAfterMinutes: 5,
      severity: 'INFO' }
  end

  def search_payload(value)
    { limit: 999,
      offset: 0,
      query: [{ key: 'status', value: value, matchingMethod: 'EXACT' }],
      sort: { field: 'status', ascending: true } }
  end
end
