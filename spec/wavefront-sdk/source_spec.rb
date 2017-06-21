#!/usr/bin/env ruby

require_relative '../spec_helper'

SOURCE = '74a247a9-f67c-43ad-911f-fabafa9dc2f3joyent'
SOURCE_BODY = {
  sourceName: 'source.name',
  tags: {
    sourceTag1: true
  },
  description: 'Source Description'
}.freeze

# Unit tests for Source class
#
class WavefrontSourceTest < WavefrontTestBase
  def test_list
    should_work(:list, [], '')
    should_work(:list, 10, '?limit=10')
    should_work(:list, [10, 'mysource'], '?limit=10&cursor=mysource')
    should_work(:list, [nil, 'mysource'], '?cursor=mysource')
  end

  def test_create
    should_work(:create, SOURCE_BODY, '', :post,
                JSON_POST_HEADERS, SOURCE_BODY.to_json)
    assert_raises(ArgumentError) { wf.create }
    assert_raises(ArgumentError) { wf.create('test') }
  end

  def test_describe
    should_work(:describe, SOURCE, SOURCE)
    assert_raises(ArgumentError) { wf.describe }
  end

  def test_delete
    should_work(:delete, SOURCE, SOURCE, :delete)
    should_be_invalid(:delete)
  end

  def test_update
    should_work(:update, [SOURCE, SOURCE_BODY, false], SOURCE, :put,
                JSON_POST_HEADERS, SOURCE_BODY.to_json)
    should_be_invalid(:update, ['!invalid source!', SOURCE_BODY])
    assert_raises(ArgumentError) { wf.update }
  end

  def test_tags
    tag_tester(SOURCE)
  end
end
