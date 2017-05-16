#!/usr/bin/env ruby

require 'date'
require_relative '../spec_helper'

SERIES = 'test.metric'.freeze
T = Time.now.freeze
T_MS = T.to_datetime.strftime('%Q').freeze
TE = (T + 10).freeze
TE_MS = TE.to_datetime.strftime('%Q')
Q = "ts(\"#{SERIES}\")".freeze
QE = URI.encode(Q).freeze

# Unit tests for Query class
#
class WavefrontQueryTest < WavefrontTestBase
  def api_base
    'chart'
  end

  def test_query
    should_work(:query, [Q, 'd', T_MS], "api?q=#{QE}&g=d&s=#{T_MS}")
    should_work(:query, [Q, 'h', T], "api?q=#{QE}&g=h&s=#{T_MS}")
    should_work(:query, [Q, 'm', T, TE],
                "api?q=#{QE}&g=m&s=#{T_MS}&e=#{TE_MS}")
    should_work(:query, [Q, 'h', T, nil, {}], "api?q=#{Q}&g=h&s=#{T_MS}")
    should_work(:query, [Q, 'h', T, nil, { strict: true,
                                           summarization: 'MAX' }],
                "api?q=#{QE}&g=h&s=#{T_MS}&strict=true&summarization=MAX")

    assert_raises(ArgumentError) { wf.query }

    assert_raises(Wavefront::Exception::InvalidGranularity) do
      wf.query('ts("m")', 'x')
    end

    assert_raises(Wavefront::Exception::InvalidTimestamp) do
      wf.query('ts("m")', 'd')
    end
  end

  def test_raw
    should_work(:raw, [SERIES, 'src'], "raw?metric=#{SERIES}&source=src")
    should_work(:raw, [SERIES, 'src', T],
                "raw?metric=#{SERIES}&source=src&startTime=#{T_MS}")
    should_work(:raw, [SERIES, 'src', T, TE],
                "raw?metric=#{SERIES}&source=src&startTime=#{T_MS}" \
                "&endTime=#{TE_MS}")
    assert_raises(ArgumentError) { wf.raw }
  end
end
