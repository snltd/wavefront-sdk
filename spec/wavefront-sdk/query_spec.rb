#!/usr/bin/env ruby

require 'cgi'
require 'date'
require_relative '../spec_helper'

# Unit tests for Query class
#
class WavefrontQueryTest < WavefrontTestBase
  attr_reader :series, :t_start, :t_start_in_ms, :t_end, :t_end_in_ms,
              :query, :escaped_query

  def setup_fixtures
    @series = 'test.metric'
    @t_start = Time.now
    @t_start_in_ms = t_start.to_datetime.strftime('%Q')
    @t_end = t_start + 10
    @t_end_in_ms = t_end.to_datetime.strftime('%Q')
    @query = "ts(\"#{series}\")"
    @escaped_query = CGI.escape(query)
  end

  def test_query
    assert_gets("/api/v2/chart/api?q=#{escaped_query}&g=d&" \
                "s=#{t_start_in_ms}") do
      wf.query(query, 'd', t_start_in_ms)
    end

    assert_gets("/api/v2/chart/api?q=#{escaped_query}&g=h&" \
                "s=#{t_start_in_ms}") do
      wf.query(query, 'h', t_start)
    end

    assert_gets("/api/v2/chart/api?q=#{escaped_query}&g=m&" \
                "s=#{t_start_in_ms}&e=#{t_end_in_ms}") do
      wf.query(query, 'm', t_start, t_end)
    end

    assert_gets("/api/v2/chart/api?q=#{query}&g=h&s=#{t_start_in_ms}") do
      wf.query(query, 'h', t_start, nil, {})
    end

    assert_gets("/api/v2/chart/api?q=#{escaped_query}&g=h&" \
                "s=#{t_start_in_ms}&strict=true&summarization=MAX") do
      wf.query(query, 'h', t_start, nil, strict: true,
                                         summarization: 'MAX')
    end

    assert_raises(ArgumentError) { wf.query }

    assert_raises(Wavefront::Exception::InvalidGranularity) do
      wf.query('ts("m")', 'x')
    end

    assert_raises(Wavefront::Exception::InvalidTimestamp) do
      wf.query('ts("m")', 'd')
    end
  end

  def test_raw
    assert_gets("/api/v2/chart/raw?metric=#{series}&source=src") do
      wf.raw(series, 'src')
    end

    assert_gets("/api/v2/chart/raw?metric=#{series}&source=src&" \
                "startTime=#{t_start_in_ms}") do
      wf.raw(series, 'src', t_start)
    end

    assert_gets("/api/v2/chart/raw?metric=#{series}&source=src&" \
                "startTime=#{t_start_in_ms}" \
                "&endTime=#{t_end_in_ms}") do
      wf.raw(series, 'src', t_start, t_end)
    end

    assert_raises(ArgumentError) { wf.raw }
  end
end
