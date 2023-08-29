#!/usr/bin/env ruby
# frozen_string_literal: true

require_relative '../spec_helper'

# Unit tests for Usage class
#
class WavefrontUsageTest < WavefrontTestBase
  def test_export_csv
    assert_raises(ArgumentError) { wf.export_csv }

    assert_gets("/api/v2/usage/exportcsv?startTime=#{t_start}") do
      wf.export_csv(t_start)
    end

    assert_gets(
      "/api/v2/usage/exportcsv?startTime=#{t_start}&endTime=#{t_end}"
    ) do
      wf.export_csv(t_start, t_end)
    end
  end

  private

  def t_start
    1_577_890_000
  end

  def t_end
    1_577_899_999
  end
end
