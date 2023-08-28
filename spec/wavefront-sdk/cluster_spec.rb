#!/usr/bin/env ruby
# frozen_string_literal: true

require_relative '../spec_helper'
require_relative '../test_mixins/general'

# Unit tests for Cluster class
#
class WavefrontClusterTest < WavefrontTestBase
  def test_describe
    assert_gets('/api/v2/cluster/info') { wf.describe }
  end
end
