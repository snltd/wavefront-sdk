#!/usr/bin/env ruby
# frozen_string_literal: true

require_relative '../spec_helper'
require_relative '../../lib/wavefront-sdk/defs/version'

# Tests for things that aren't in the SDK itself.
#
class WavefrontMiscTest < MiniTest::Test
  # Check the latest version mentioned in the changelog is the version the SDK
  # defines itself as.
  #
  def test_version_vs_history
    history_file = WF_SDK_LOCATION + 'HISTORY.md'
    history_vers = IO.read(history_file).match(/^## (\d+\.\d+\.\d+) \(/)
    assert_equal(WF_SDK_VERSION, history_vers.captures.first)
  end
end
