#!/usr/bin/env ruby

require_relative '../../spec_helper'
require_relative '../../../lib/wavefront-sdk/stdlib/hash'
require 'spy/integration'

# Test extensions to stdlib hash class
#
class HashTest < MiniTest::Test
  def test_to_wf_tag
    assert_equal({}.to_wf_tag, '')
    assert_equal({ gt1: 'gv1', gt2: 'gv2' }.to_wf_tag,
                 'gt1="gv1" gt2="gv2"')
    assert_equal({ tag: 'value' }.to_wf_tag, 'tag="value"')
    assert_equal({ tag: 'two words' }.to_wf_tag, 'tag="two words"')
    assert_equal('tag="say \"hi\""', { tag: 'say "hi"' }.to_wf_tag)
    assert_equal('tag1="say \"hi\"" tag2="some stuff!"',
                 { tag1: 'say "hi"', tag2: 'some stuff!' }.to_wf_tag)
  end
end
