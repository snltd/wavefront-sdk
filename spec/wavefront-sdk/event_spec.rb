#!/usr/bin/env ruby

require_relative './spec_helper'

# Unit tests for event class
#
class WavefrontEventTest < WavefrontTestBase
  def should_fail_tags(method)
    assert_raises(Wavefront::Exception::InvalidEvent) do
      wf.send(method, '!!invalid!!', 'tag1')
    end

    assert_raises(Wavefront::Exception::InvalidString) do
      wf.send(method, EVENT, '<!!!>')
    end
  end

  def test_list
    opts = {
      earliestStartTimeEpochMillis: 1491592854000,
      latestStartTimeEpochMillis: 1491592864000,
      cursor: 1491592854000,
      limit: 50
    }

    assert_raises(Wavefront::Exception::InvalidTimestamp) {
      o = opts
      o[earliestStartTimeEpochMillis] = 1234556
      wf.list(o)
    }

    assert_raises(Wavefront::Exception::InvalidTimestamp) {
      o = opts
      o[latestStartTimeEpochMillis] = 1234556
      wf.list(o)
    }

    assert_raises(Wavefront::Exception::InvalidLimit) {
      o = opts
      o[limit] = 'abc'
      wf.list(o)
    }

    should_work('list', opts)

    opts.keys.each do |k|
      opts.delete(k)
      should_work('list', opts)
    end
  end

  def test_describe
    should_work('describe', EVENT, EVENT)
    should_be_invalid('describe', 'abcdefg')
    assert_raises(ArgumentError) { wf.describe }
  end

  def test_create
    should_work('create', EVENT, EVENT, :post)
    assert_raises(ArgumentError) { wf.create }
  end

  def test_close
    should_work('close', EVENT, "#{EVENT}/close", :post)
    should_be_invalid('close', 'abcdefg')
    assert_raises(ArgumentError) { wf.close }
  end

  def test_delete
    should_work('delete', EVENT, EVENT, :delete)
    should_be_invalid('delete', 'abcdefg')
    assert_raises(ArgumentError) { wf.delete }
  end

  def test_tags
    should_work('tags', EVENT, "#{EVENT}/tag")
    should_be_invalid('tags')
  end

  def test_tag_set
    should_work('tag_set', [EVENT, 'tag'],
                ["#{EVENT}/tag", ['tag'].to_json], :post,
                JSON_POST_HEADERS)
    should_work('tag_set', [EVENT, %w(tag1 tag2)],
                ["#{EVENT}/tag", %w(tag1 tag2).to_json], :post,
                JSON_POST_HEADERS)
    should_fail_tags('tag_set')
  end

  def test_tag_add
    should_work('tag_add', [EVENT, 'tagval'],
                ["#{EVENT}/tag/tagval", nil], :put, JSON_POST_HEADERS)
    should_fail_tags('tag_add')
  end

  def test_tag_delete
    should_work('tag_delete', [EVENT, 'tagval'],
                "#{EVENT}/tag/tagval", :delete)
    should_fail_tags('tag_delete')
  end
end
