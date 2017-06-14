#!/usr/bin/env ruby

require_relative '../spec_helper'

DASHBOARD = 'test_dashboard'.freeze
DASHBOARD_BODY = {
  name: 'SDK Dashboard test',
  id: 'sdk-test',
  description: 'dummy test dashboard',
  sections: [
    name: 'Section 1',
    rows: [
      { charts: [
        name: 'S1 Chart1',
        description: 'chart',
        sources: [
          { name: 'S1 C1 Source 1',
            query: 'ts("some.series")' }
        ]
      ] }
    ]
  ]
}.freeze

# Unit tests for dashboard class
#
class WavefrontDashboardTest < WavefrontTestBase
  def test_list
    should_work(:list, 10, '?offset=10&limit=100')
  end

  def test_create
    should_work(:create, DASHBOARD_BODY, '', :post,
                JSON_POST_HEADERS, DASHBOARD_BODY.to_json)
    assert_raises(ArgumentError) { wf.create }
    assert_raises(ArgumentError) { wf.create('test') }
  end

  def test_describe
    should_work(:describe, DASHBOARD, DASHBOARD)
    assert_raises(ArgumentError) { wf.describe }
  end

  def test_describe_v
    should_work(:describe, [DASHBOARD, 4], "#{DASHBOARD}/history/4")
  end

  def test_delete
    should_work(:delete, DASHBOARD, DASHBOARD, :delete)
    should_be_invalid(:delete)
  end

  def test_history
    should_work(:history, DASHBOARD, "#{DASHBOARD}/history")
    should_be_invalid(:history)
  end

  def test_update
    should_work(:update, [DASHBOARD, DASHBOARD_BODY, false],
                DASHBOARD, :put, JSON_POST_HEADERS,
                DASHBOARD_BODY.to_json)
    should_be_invalid(:update, ['!invalid dash!', DASHBOARD_BODY])
    assert_raises(ArgumentError) { wf.update }
  end

  def test_tags
    tag_tester(DASHBOARD)
  end

  def test_undelete
    should_work(:undelete, DASHBOARD, ["#{DASHBOARD}/undelete",
                                       nil], :post, POST_HEADERS)
    should_be_invalid(:undelete)
  end
end
