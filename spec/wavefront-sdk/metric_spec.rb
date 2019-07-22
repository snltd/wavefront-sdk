#!/usr/bin/env ruby

require_relative '../spec_helper'

# Unit tests for Metric class
#
class WavefrontMetricTest < WavefrontTestBase
  def test_detail
    assert_gets('/api/v2/chart/metric/detail?m=test.metric') do
      wf.detail('test.metric')
    end

    assert_gets('/api/v2/chart/metric/detail?m=path&h=host1&h=host2') do
      wf.detail('path', %w[host1 host2])
    end

    assert_gets('/api/v2/chart/metric/detail?m=test.metric&' \
                'h=host1&h=host2&c=abc') do
      wf.detail('test.metric', %w[host1 host2], 'abc')
    end

    assert_raises(ArgumentError) { wf.detail }
    assert_raises(ArgumentError) { wf.detail('m1', 'm2') }
  end
end
