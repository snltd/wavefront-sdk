#!/usr/bin/env ruby

require_relative '../../spec_helper'
require_relative '../../../lib/wavefront-sdk/metric_type/gauge'

WRITER_CREDS = { proxy: 'wavefront', port: 2878 }.freeze

# Test for gauge specifics. The sending mechanism is tested by
# base_spec
#
class WavefrontMetricTypeGaugeTest < MiniTest::Test
  attr_reader :wf

  def setup(opts = {})
    @wf = Wavefront::MetricType::Counter.new(WRITER_CREDS, {}, opts)
  end
end
