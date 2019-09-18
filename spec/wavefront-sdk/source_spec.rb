#!/usr/bin/env ruby
# frozen_string_literal: true

require_relative '../spec_helper'
require_relative '../test_mixins/general'
require_relative '../test_mixins/tag'

# Unit tests for Source class
#
class WavefrontSourceTest < WavefrontTestBase
  include WavefrontTest::Create
  include WavefrontTest::Delete
  include WavefrontTest::Describe
  include WavefrontTest::Tag
  include WavefrontTest::Update

  def test_list
    assert_gets('/api/v2/source') { wf.list }
    assert_gets('/api/v2/source?limit=10') { wf.list(10) }

    assert_gets('/api/v2/source?limit=10&cursor=mysource') do
      wf.list(10, 'mysource')
    end

    assert_gets('/api/v2/source?cursor=mysource') do
      wf.list(nil, 'mysource')
    end
  end

  private

  def api_class
    'source'
  end

  def id
    '74a247a9-f67c-43ad-911f-fabafa9dc2f3joyent'
  end

  def invalid_id
    '(>_<)'
  end

  def payload
    { sourceName: 'source.name',
      tags: { sourceTag1: true },
      description: 'Source Description' }
  end
end
