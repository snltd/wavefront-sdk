#!/usr/bin/env ruby

require_relative '../../spec_helper'
require_relative '../../../lib/wavefront-sdk/metric_type/gauge'

# Test for gauge specifics. The sending mechanism is tested by
# base_spec
#
class WavefrontMetricTypeGaugeTest < MiniTest::Test
  attr_reader :wf

  def setup(opts = {})
    @wf = Wavefront::MetricType::Counter.new(W_CREDS, {}, opts)
  end
end
