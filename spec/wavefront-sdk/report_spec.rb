#!/usr/bin/env ruby
# frozen_string_literal: true

require_relative '../spec_helper'
require_relative 'resources/dummy_points'

REPORT_HEADERS = POST_HEADERS.merge('Content-Type': 'application/octet-stream')

# Unit tests for Report class
#
class WavefrontReportTest < WavefrontTestBase
  def test_write
    assert_posts('/report?f=wavefront', POINT_L, :octet) do
      wf.write(POINT)
    end
  end
end
