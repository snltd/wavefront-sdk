#!/usr/bin/env ruby
# frozen_string_literal: true

require_relative '../../spec_helper'
require_relative '../../../lib/wavefront-sdk/unstable/chart'

# Unit tests for Chart class
#
class WavefrontChartTest < MiniTest::Test
  attr_reader :wf

  def setup
    @wf = Wavefront::Unstable::Chart.new(CREDS)
  end

  def test_all_metrics
    assert_gets('/chart/metrics/all?l=100&q=&trie=true') do
      wf.metrics_under('')
    end
  end

  def test_metrics_under
    assert_gets('/chart/metrics/all?l=100&q=test.path&trie=true') do
      wf.metrics_under('test.path')
    end

    assert_gets('/chart/metrics/all?l=10&q=test.path&trie=true') do
      wf.metrics_under('test.path', nil, 10)
    end

    assert_gets('/chart/metrics/all?l=100&p=last.one&q=test.path&trie=true') do
      wf.metrics_under('test.path', 'last.one')
    end
  end

  def dummy_response
    { metrics: ['test data'] }.to_json
  end
end
