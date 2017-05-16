#!/usr/bin/env ruby

require_relative '../spec_helper'

# Unit tests for Metric class
#
class WavefrontMetricTest < WavefrontTestBase
  def api_base
    'chart/metric'
  end

  def test_detail
    should_work(:detail, 'metric.1', 'detail?m=metric.1')
    should_work(:detail, ['metric.1', %w(host1 host2)],
                'detail?m=metric.1&h=host1&h=host2')
    should_work(:detail, ['metric.1', %w(host1 host2), 'abc'],
                'detail?m=metric.1&h=host1&h=host2&c=abc')
    assert_raises(ArgumentError) { wf.detail }
    assert_raises(ArgumentError) { wf.detail('m1', 'm2') }
  end
end
