#!/usr/bin/env ruby

require_relative '../spec_helper'
require_relative '../resources/dummy_points'

HEADERS = POST_HEADERS.merge('Content-Type': 'application/octet-stream')
# Unit tests for Report class
#
class WavefrontReportTest < WavefrontTestBase
  def uri_base
    "https://#{CREDS[:endpoint]}/report"
  end

  def test_write
    should_work(:write, POINT, ['?f=graphite_v2', nil],
                :post, HEADERS, POINT_L)
  end
end
