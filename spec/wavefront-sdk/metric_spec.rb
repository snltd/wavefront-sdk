#!/usr/bin/env ruby

require_relative './spec_helper'

# Unit tests for Metric class
#
class WavefrontMetricTest < WavefrontTestBase
  def test_detail
    should_work(:detail, 'metric.1', 'detail?metric.1')
    should_work(:detail, ['metric.1', ['h1', 'h2']],
                          'detail?metric.1&h=h1&h=h2')
    should_work(:detail, ['metric.1', ['h1', 'h2'], 'abc'],
                          'detail?metric.1&h=h1&h=h2&c=abc')
    assert_raises(ArgumentError) { wf.detail }
    assert_raises(ArgumentError) { wf.detail('m1', 'm2') }
    assert_raises(ArgumentError) { wf.detail('m1', ['m2'], []) }
  end
end
