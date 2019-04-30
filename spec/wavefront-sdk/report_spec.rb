#!/usr/bin/env ruby

require_relative '../spec_helper'
require_relative 'resources/dummy_points'

REPORT_HEADERS = POST_HEADERS.merge('Content-Type': 'application/octet-stream')

# Unit tests for Report class
#
class WavefrontReportTest < WavefrontTestBase
  def uri_base
    "https://#{CREDS[:endpoint]}/report"
  end

  def test_write
    should_work(:write, POINT, ['?f=wavefront', nil],
                :post, REPORT_HEADERS, POINT_L)
  end
end
