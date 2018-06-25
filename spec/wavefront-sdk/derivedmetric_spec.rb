#!/usr/bin/env ruby

require_relative '../spec_helper'

DERIVED_METRIC = '1529926075038'.freeze
DERIVED_METRIC_BODY = {
  "minutes": 5,
  "name": "test_1",
  "query": "aliasMetric(ts(\"test.metric\"), \"derived.test_1\")",
  "tags": {
    "customerTags": [
      "test"
    ]
  },
  "includeObsoleteMetrics": false,
  "processRateMinutes": 1,
}.freeze

# Unit tests for dashboard class
#
class WavefrontDerivedMetricTest < WavefrontTestBase
  def test_list
    should_work(:list, 10, '?offset=10&limit=100')
  end

  def test_create
    should_work(:create, DERIVED_METRIC_BODY, '', :post,
                JSON_POST_HEADERS, DERIVED_METRIC_BODY.to_json)
    assert_raises(ArgumentError) { wf.create }
    assert_raises(ArgumentError) { wf.create('test') }
  end

  def test_describe
    should_work(:describe, DERIVED_METRIC, DERIVED_METRIC)
    assert_raises(ArgumentError) { wf.describe }
  end

  def test_describe_v
    should_work(:describe, [DERIVED_METRIC, 4], "#{DERIVED_METRIC}/history/4")
  end

  def test_delete
    should_work(:delete, DERIVED_METRIC, DERIVED_METRIC, :delete)
    should_be_invalid(:delete)
  end

  def test_history
    should_work(:history, DERIVED_METRIC, "#{DERIVED_METRIC}/history")
    should_be_invalid(:history)
  end

  def test_update
    should_work(:update, [DERIVED_METRIC, DERIVED_METRIC_BODY, false],
                DERIVED_METRIC, :put, JSON_POST_HEADERS,
                DERIVED_METRIC_BODY.to_json)
    should_be_invalid(:update, ['!invalid derived metric!',
                                DERIVED_METRIC_BODY])
    assert_raises(ArgumentError) { wf.update }
  end

  def test_tags
    tag_tester(DERIVED_METRIC)
  end

  def test_undelete
    should_work(:undelete, DERIVED_METRIC, ["#{DERIVED_METRIC}/undelete",
                                       nil], :post, POST_HEADERS)
    should_be_invalid(:undelete)
  end
end
