#!/usr/bin/env ruby

require_relative '../spec_helper'
require_relative '../test_mixins/general'
require_relative '../test_mixins/tag'

# Unit tests for event class
#
class WavefrontEventTest < WavefrontTestBase
  include WavefrontTest::Tag
  include WavefrontTest::Create
  include WavefrontTest::Delete
  include WavefrontTest::Describe
  include WavefrontTest::Update

  def test_list
    t1 = Time.now - 600
    t2 = Time.now
    tms1 = t1.to_datetime.strftime('%Q')
    tms2 = t2.to_datetime.strftime('%Q')

    assert_raises(ArgumentError) { wf.list }

    time_qs = ["earliestStartTimeEpochMillis=#{tms1}",
               "latestStartTimeEpochMillis=#{tms2}",
               'limit=100'].join('&')

    assert_gets("/api/v2/event?#{time_qs}") { wf.list(t1, t2) }
    assert_gets("/api/v2/event?#{time_qs}") { wf.list(tms1, tms2) }

    assert_raises(Wavefront::Exception::InvalidTimestamp) do
      wf.list(t1, 'abc')
    end
  end

  def test_close
    assert_posts("/api/v2/event/#{id}/close") do
      wf.close(id)
    end

    assert_invalid_id { wf.close(invalid_id) }
    assert_raises(ArgumentError) { wf.close }
  end

  private

  def id
    '1481553823153:testev'
  end

  def invalid_id
    'nonsense'
  end

  def api_class
    'event'
  end

  def payload
    { name:        'test_event',
      annotations: {
        severity: 'info',
        type:     'SDK test event',
        details:  'an imaginary event to test the SDK'
      },
      hosts:       %w[host1 host2],
      startTime:   1_493_385_089_000,
      endTime:     1_493_385_345_678,
      tags:        %w[tag1 tag2],
      isEphemeral: false }
  end
end
