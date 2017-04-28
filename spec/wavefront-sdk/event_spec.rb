#!/usr/bin/env ruby

require_relative './spec_helper'

EVENT_BODY = {
  name:        'test_event',
  annotations: {
    severity: 'info',
    type:     'SDK test event',
    details:  'an imaginary event to test the SDK',
  },
  hosts:       ['host1', 'host2'],
  startTime:   1493385089000,
  endTime:     1493385345678,
  tags:        ['tag1', 'tag2'],
  isEphemeral: false,
}

# Unit tests for event class
#
class WavefrontEventTest < WavefrontTestBase
=begin
  def should_fail_tags(method)
    assert_raises(Wavefront::Exception::InvalidEvent) do
      wf.send(method, '!!invalid!!', 'tag1')
    end

    assert_raises(Wavefront::Exception::InvalidString) do
      wf.send(method, EVENT, '<!!!>')
    end
  end
=end

  def test_list
    should_work('list', nil, '?limit=100')
    should_work('list', 1493382053000,
                '?earliestStartTimeEpochMillis=1493382053000&limit=100')

    assert_raises(Wavefront::Exception::InvalidTimestamp) {
      wf.list(Time.now)
    }
  end

  def test_create
    body_test(hash:     EVENT_BODY,
              required: [:name],
              optional: [:tags, :hosts, :isEphemeral, :startTime, :endTime],
              invalid:  [[Wavefront::Exception::InvalidTimestamp,
                          [:startTime, :endTime]]])
  end

=begin
  def test_describe
    should_work('describe', EVENT, EVENT)
    should_be_invalid('describe', 'abcdefg')
    assert_raises(ArgumentError) { wf.describe }
  end
  #def test_close
    #should_work('close', EVENT, "#{EVENT}/close", :post)
    #should_be_invalid('close', 'abcdefg')
    #assert_raises(ArgumentError) { wf.close }
  #end

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
=end
end
