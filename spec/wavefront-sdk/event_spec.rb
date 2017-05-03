#!/usr/bin/env ruby

require_relative './spec_helper'

EVENT = '1481553823153:testev'.freeze
EVENT_BODY = {
  name:        'test_event',
  annotations: {
    severity: 'info',
    type:     'SDK test event',
    details:  'an imaginary event to test the SDK'
  },
  hosts:       %w(host1 host2),
  startTime:   1493385089000,
  endTime:     1493385345678,
  tags:        %w(tag1 tag2),
  isEphemeral: false
}.freeze

# Unit tests for event class
#
class WavefrontEventTest < WavefrontTestBase
  def test_list
    should_work(:list, nil, '?limit=100')
    should_work(:list, 1493382053000,
                '?earliestStartTimeEpochMillis=1493382053000&limit=100')

    assert_raises(Wavefront::Exception::InvalidTimestamp) do
      wf.list(Time.now)
    end
  end

  def test_create
    should_work(:create, EVENT_BODY, '', :post,
                JSON_POST_HEADERS, EVENT_BODY.to_json)
    assert_raises(ArgumentError) { wf.create }
    assert_raises(ArgumentError) { wf.create('test') }
  end

  def test_describe
    should_work(:describe, EVENT, EVENT)
    should_be_invalid(:describe, 'abcdefg')
    assert_raises(ArgumentError) { wf.describe }
  end

  def test_close
    should_work(:close, EVENT, "#{EVENT}/close", :post, POST_HEADERS)
    should_be_invalid(:close, 'abcdefg')
    assert_raises(ArgumentError) { wf.close }
  end

  def test_update
    should_work(:update, [EVENT, EVENT_BODY], EVENT, :put,
                JSON_POST_HEADERS, EVENT_BODY.to_json)
    should_be_invalid(:update, ['abcde', EVENT_BODY])
    assert_raises(ArgumentError) { wf.update }
  end

  def test_delete
    should_work(:delete, EVENT, EVENT, :delete)
    should_be_invalid(:delete, 'abcdefg')
    assert_raises(ArgumentError) { wf.delete }
  end

  def test_tags
    tag_tester(EVENT)
  end
end
