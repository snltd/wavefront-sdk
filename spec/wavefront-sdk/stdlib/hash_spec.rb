#!/usr/bin/env ruby
# frozen_string_literal: true

require_relative '../../spec_helper'
require_relative '../../../lib/wavefront-sdk/stdlib/hash'

# Test extensions to stdlib hash class
#
class HashTest < Minitest::Test
  def test_to_wf_tag
    assert_equal('', {}.to_wf_tag)
    assert_equal('gt1="gv1" gt2="gv2"',
                 { gt1: 'gv1', gt2: 'gv2' }.to_wf_tag)
    assert_equal('tag="value"', { tag: 'value' }.to_wf_tag)
    assert_equal('tag="two words"', { tag: 'two words' }.to_wf_tag)
    assert_equal('tag="say \"hi\""', { tag: 'say "hi"' }.to_wf_tag)
    assert_equal('tag1="say \"hi\"" tag2="some stuff!"',
                 { tag1: 'say "hi"', tag2: 'some stuff!' }.to_wf_tag)
  end

  def test_cleanse
    assert_equal({ k1: 1, k3: 3 }, { k1: 1, k2: nil, k3: 3 }.cleanse)
    assert_equal({ k1: 1, k2: 2, k3: 3 }, { k1: 1, k2: 2, k3: 3 }.cleanse)
    assert_equal({}, { k1: nil, k2: false, k3: false }.cleanse)
  end
end
