#!/usr/bin/env ruby

require_relative './spec_helper'
require_relative '../../lib/wavefront-sdk/alert'

class WavefrontAlertTest < MiniTest::Test
  attr_reader :wf, :wf_noop, :uri_base, :headers

  def setup
    @wf = Wavefront::Alert.new(CREDS)
    @uri_base = "https://#{CREDS[:endpoint]}/api/v2/alert"
    @headers = { 'Authorization' => "Bearer #{CREDS[:token]}" }
  end

  def should_fail_tags(method)
    assert_raises(Wavefront::Exception::InvalidAlert) do
      wf.send(method, 'abc', 'tag1')
    end

    assert_raises(Wavefront::Exception::InvalidString) do
      wf.send(method, ALERT, '<!!!>')
    end
  end

  def test_list
    should_work('list', 10, '?offset=10&limit=100')
  end

  def test_describe
    should_work('describe', ALERT, ALERT)
    assert_raises(ArgumentError) { wf.describe }
    assert_raises(Wavefront::Exception::InvalidAlert) { wf.describe('abc') }
  end
  def test_describe_v
    should_work('describe', [ALERT, 4], "#{ALERT}/history/4")
  end

  def test_delete
    should_work('delete', ALERT, ALERT, :delete)
    assert_raises(Wavefront::Exception::InvalidAlert) { wf.delete('abc') }
  end

  def test_history
    should_work('history', ALERT, "#{ALERT}/history")
    assert_raises(Wavefront::Exception::InvalidAlert) { wf.history('abc') }
  end

  def test_snooze
    should_work('snooze', ALERT, ["#{ALERT}/snooze", 3600], :post,
                POST_HEADERS)
    assert_raises(Wavefront::Exception::InvalidAlert) { wf.snooze('abc') }
  end

  def test_tags
    should_work('tags', ALERT, "#{ALERT}/tag")
    assert_raises(Wavefront::Exception::InvalidAlert) { wf.tags('abc') }
  end

  def test_tag_set
    should_work('tag_set', [ALERT, 'tag'], ["#{ALERT}/tag",
                ['tag'].to_json], :post, JSON_POST_HEADERS)
    should_work('tag_set', [ALERT, ['tag1', 'tag2']], ["#{ALERT}/tag",
                ['tag1', 'tag2'].to_json], :post, JSON_POST_HEADERS)
    should_fail_tags('tag_set')
  end

  def test_tag_add
    should_work('tag_add', [ALERT, 'tagval'], ["#{ALERT}/tag/tagval",
                nil], :put, JSON_POST_HEADERS)
    should_fail_tags('tag_add')
  end

  def test_tag_delete
    should_work('tag_delete', [ALERT, 'tagval'], "#{ALERT}/tag/tagval",
                :delete)
    should_fail_tags('tag_delete')
  end

  def test_undelete
    should_work('undelete', ALERT, ["#{ALERT}/undelete", nil], :post,
                POST_HEADERS)
    assert_raises(Wavefront::Exception::InvalidAlert) { wf.undelete('abc') }
  end

  def test_unsnooze
    should_work('unsnooze', ALERT, ["#{ALERT}/unsnooze", nil], :post,
                POST_HEADERS)
    assert_raises(Wavefront::Exception::InvalidAlert) { wf.unsnooze('abc') }
  end

  def test_summary
    should_work('summary', nil, '/summary')
  end
end
