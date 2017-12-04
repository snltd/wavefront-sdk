#!/usr/bin/env ruby

require_relative '../spec_helper'

EVENT = '1481553823153:testev'.freeze
EVENT_BODY = {
  name:        'test_event',
  annotations: {
    severity: 'info',
    type:     'SDK test event',
    details:  'an imaginary event to test the SDK'
  },
  hosts:       %w[host1 host2],
  startTime:   1_493_385_089_000,
  endTime:     1_493_385_345_678,
  tags:        %w[tag1 tag2],
  isEphemeral: false
}.freeze

# Unit tests for event class
#
class WavefrontEventTest < WavefrontTestBase
  def test_list
    t1 = Time.now - 600
    t2 = Time.now
    tms1 = t1.to_datetime.strftime('%Q')
    tms2 = t2.to_datetime.strftime('%Q')

    assert_raises(ArgumentError) {  wf.list }
    assert_raises(ArgumentError) {  wf.list(tms1) }

    should_work(:list, [t1, t2],
                "?earliestStartTimeEpochMillis=#{tms1}" \
                "&latestStartTimeEpochMillis=#{tms2}" \
                '&limit=100')

    should_work(:list, [tms1, tms2],
                "?earliestStartTimeEpochMillis=#{tms1}" \
                "&latestStartTimeEpochMillis=#{tms2}" \
                '&limit=100')

    assert_raises(Wavefront::Exception::InvalidTimestamp) do
      wf.list(t1, 'abc')
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
    should_work(:update, [EVENT, EVENT_BODY, false], EVENT, :put,
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
