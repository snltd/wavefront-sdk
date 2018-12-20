#!/usr/bin/env ruby

require_relative '../spec_helper'
require 'spy/integration'

ALERT = '1481553823153'.freeze
ALERT_BODY = {
  name:               'SDK test alert',
  target:             'user@example.com',
  condition:          'ts("app.errors") > 0',
  displayExpression:  'ts("app.errors")',
  minutes:             5,
  resolveAfterMinutes: 5,
  severity:            'INFO'
}.freeze

def search_body(val)
  { limit: 999,
    offset: 0,
    query: [
      { key: 'status',
        value: val,
        matchingMethod: 'EXACT' }
    ],
    sort: { field: 'status', ascending: true } }
end

# Unit tests for Alert class
#
class WavefrontAlertTest < WavefrontTestBase
  def test_list
    should_work(:list, 10, '?offset=10&limit=100')
  end

  def test_list_all
    should_work(:list, [0, :all], '?limit=999&offset=0')
    should_work(:list, [20, :all], '?limit=20&offset=0')
  end

  def test_update_keys
    assert_instance_of(Array, wf.update_keys)
    wf.update_keys.each { |k| assert_instance_of(Symbol, k) }
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

  def test_install
    should_work(:install, ALERT, "#{ALERT}/install", :post)
    should_be_invalid(:install)
  end

  def test_snooze
    should_work(:snooze, ALERT, "#{ALERT}/snooze", :post, POST_HEADERS)
    should_work(:snooze, [ALERT, 3600], "#{ALERT}/snooze?seconds=3600",
                :post, POST_HEADERS)
    should_be_invalid(:snooze)
  end

  def test_update
    should_work(:update, [ALERT, ALERT_BODY, false], ALERT, :put,
                JSON_POST_HEADERS, ALERT_BODY)
    should_be_invalid(:update, ['abcde', ALERT_BODY])
    assert_raises(ArgumentError) { wf.update }
  end

  def test_tags
    tag_tester(ALERT)
  end

  def test_undelete
    should_work(:undelete, ALERT, ["#{ALERT}/undelete", nil], :post,
                POST_HEADERS)
    should_be_invalid(:undelete)
  end

  def test_uninstall
    should_work(:uninstall, ALERT, "#{ALERT}/uninstall", :post)
    should_be_invalid(:uninstall)
  end

  def test_unsnooze
    should_work(:unsnooze, ALERT, ["#{ALERT}/unsnooze", nil], :post,
                POST_HEADERS)
    should_be_invalid(:unsnooze)
  end

  def test_summary
    should_work(:summary, nil, 'summary')
  end

  def test_alerts_in_state
    should_work(:alerts_in_state, 'some_state', '/api/v2/search/alert',
                :post, {}, search_body('some_state'))
  end

  def test_firing
    should_work(:firing, nil, '/api/v2/search/alert', :post, {},
                search_body('firing'))
  end

  def test_active
    should_work(:firing, nil, '/api/v2/search/alert', :post, {},
                search_body('firing'))
  end

  def test_affected_by_maintenance
    should_work(:affected_by_maintenance, nil, '/api/v2/search/alert',
                :post, {}, search_body('in_maintenance'))
  end

  def test_invalid
    should_work(:invalid, nil, '/api/v2/search/alert', :post, {},
                search_body('invalid'))
  end

  def test_in_maintenance
    should_work(:affected_by_maintenance, nil, '/api/v2/search/alert',
                :post, {}, search_body('in_maintenance'))
  end

  def test_none
    should_work(:none, nil, '/api/v2/search/alert', :post, {},
                search_body('none'))
  end

  def test_checking
    should_work(:checking, nil, '/api/v2/search/alert', :post, {},
                search_body('checking'))
  end

  def test_trash
    should_work(:trash, nil, '/api/v2/search/alert', :post, {},
                search_body('trash'))
  end

  def test_no_data
    should_work(:no_data, nil, '/api/v2/search/alert',
                :post, {}, search_body('no_data'))
  end

  def test_snoozed
    should_work(:snoozed, nil, '/api/v2/search/alert',
                :post, {}, search_body('snoozed'))
  end

  # Not a full test, because it's a recursive API call. Just test
  # the first API call is made correctly.
  #
  def test_all
    should_work(:all, nil, '?offset=0&limit=999')
  end
end
