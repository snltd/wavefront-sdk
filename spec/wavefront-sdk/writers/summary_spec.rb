#!/usr/bin/env ruby

require_relative '../../../lib/wavefront-sdk/writers/summary'
require_relative '../../spec_helper'

# Tests for summarizer
#
class WavefronWriterSummaryTest < MiniTest::Test
  attr_reader :wf

  def setup
    @wf = Wavefront::Writer::Summary.new
  end

  def test_initial
    assert_equal(0, wf.sent)
    assert_equal(0, wf.unsent)
    assert_equal(0, wf.rejected)
    assert_raises(NoMethodError) { wf.missing }
  end

  def test_increments_result_and_ok?
    wf_ok = wf.dup
    wf_ok.sent += 1
    assert_equal('OK', wf_ok.result)
    assert wf_ok.ok?
    wf_ok.rejected += 1
    refute wf_ok.ok?
    assert_equal('ERROR', wf_ok.result)

    wf_not_ok = wf.dup
    wf_not_ok.unsent += 1
    refute wf_not_ok.ok?
    assert_equal('ERROR', wf_not_ok.result)
  end

  def test_to_h
    assert_equal({ sent: 0, unsent: 0, rejected: 0 }, wf.to_h)
  end
end
