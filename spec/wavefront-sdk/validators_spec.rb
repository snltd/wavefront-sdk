#!/usr/bin/env ruby

require 'date'
require 'minitest/autorun'
require_relative './spec_helper'
require_relative '../../lib/wavefront-sdk/validators'

class WavefrontValidatorsTest < MiniTest::Test
  include Wavefront::Validators

  def good_and_bad(method, exception, good, bad)
    ex = Object.const_get("Wavefront::Exception::#{exception}")

    good.each { |m| assert send(method, m) }
    bad.each { |m| assert_raises(ex) { send(method, m) } }
  end

  def test_validate_hash
    assert_raises(ArgumentError) { validate_hash([], {}) }
    assert_raises(ArgumentError) { validate_hash({}, []) }

    h1 = { tags: %w(tag1 tag2 tag3), source: 'wfsource' }
    d1 = { source:    [:wf_source?, :required],
           tags:      [:wf_tag?],
           otherTags: [:wf_tag?] }

    assert validate_hash(h1, d1)

    d2 = { source: [:wf_source?, :required], }
    assert_raises('unknown key: tags') { validate_hash(h1, d2) }

    h2 = { tags: %w(tag1 tag2 tag3) }
    assert_raises('missing key: source') { validate_hash(h2, d1) }

    h3 = { source: '!bad source!' }
    assert_raises(Wavefront::Exception::InvalidSource) {
      validate_hash(h3, d1)
    }

    h4 = { source: 'source', thing: 123 }
    d4 = { source: [:wf_source?, :required], thing: [nil] }
    assert validate_hash(h4, d4)
  end

  def test_wf_metric_name?
    good = ['a.l33t.metric_path-passes', 'NO.NEED.TO.SHOUT',
             '"slash/allowed_in_quotes"', '"comma,allowed_in_quotes"']
    bad  = ['metric.is.(>_<)', { key: 'val' }, 'no/slash', 'no,comma', []]
    good_and_bad('wf_metric_name?', 'InvalidMetricName', good, bad)
  end

  def test_wf_string?
    good = ['string', 'valid string', 'valid, valid string.',
             'valid-string', ' VALID_string']
    bad  = ['a' * 1024, '(>_<)', { key: 'val' }, [], 123456]
    good_and_bad('wf_string?', 'InvalidString', good, bad)
  end

  def test_wf_name?
    good = %w(name name123)
    bad  = ['a' * 1024, '(>_<)', { key: 'val' }, [], 123456, '']
    good_and_bad('wf_name?', 'InvalidName', good, bad)
  end

  def test_wf_source?
    good = ['validsource1', 'valid-source', 'valid_source',
             'valid.source', 'Valid_Source', 'a' * 1023, '123456']
    bad  = ['a' * 1024, '(>_<)', { key: 'val' }, [], 123456]
    good_and_bad('wf_source?', 'InvalidSource', good, bad)
  end

  def test_wf_value?
    good = [0, 123, -10, 1.23456789, 1.23e04]
    bad = ['1', 'abc', '0', {}, []]
    good_and_bad('wf_value?', 'InvalidMetricValue', good, bad)
  end

  def test_wf_ts?
    good = [Time.now, Date.today, DateTime.now]
    bad  = ['2017-03-25 23:52:22 +0000', 1490485946,
            '#<Date: 2017-03-25 ((2457838j,0s,0n),+0s,2299161j)>']
    good_and_bad('wf_ts?', 'InvalidTimestamp', good, bad)
  end

  def test_wf_ms_ts?
    good = [Time.now.to_i * 1000]
    bad  = ['2017-03-25 23:52:22 +0000']
    good_and_bad('wf_ms_ts?', 'InvalidTimestamp', good, bad)
  end

  def test_wf_epoch?
    good = [Time.now.to_i]
    bad  = ['2017-03-25 23:52:22 +0000']
    good_and_bad('wf_epoch?', 'InvalidTimestamp', good, bad)
  end

  def test_wf_tag?
    good = ['abc', 'abc123', '__tag__', 'my:tag', ['abc', 'abc123']]
    bad = ['^^^', Time.now, 'bad tag', ['abc', '!BAD!']]
    good_and_bad('wf_tag?', 'InvalidTag', good, bad)
  end

  def test_wf_point_tags?
    good = [{},
            {tag1: 'val1', tag2: 'val2'},
            {tag1: 'val 1', tag2: 'val 2'},
            {TAG1: 'val 1', tag2: 'val 2'},
            {'TAG-1': 'val 1', tag2: 'val 2'},
            {'TAG_1': 'val 1', tag_2: 'val 2'},
            {'TAG.1': 'val 1', tag_2: 'val 2'},
            {'TAG-1': 'val 1', tag2: 'val 2'},
            {tag1: '(>_<)', tag2: '^_^'}]
    bad  = ['key=value',
            {'tag 1': 'val1', 'tag 2': 'val2'},
            {'TAG*1': 'val 1', tag_2: 'val 2'},
            {'(>_<)': 'val1', '^_^': 'val2'},
            {tag1: 'v' * 255},
            {'k' * 255 => 'val1'},
            {'k' * 130 => 'v' * 130}]
    good_and_bad('wf_point_tags?', 'InvalidTag', good, bad)
  end

  def test_wf_agent?
    good = %w(fd248f53-378e-4fbe-bbd3-efabace8d724
              917102d1-a10e-497b-ba63-95058f98d4fb)
    bad = %w(agent 17102d1-a10e-497b-ba63-95058f98d4fb)
    good_and_bad('wf_agent?', 'InvalidAgent', good, bad)
  end

  def test_wf_cloudintegration?
    good = %w(3b56f61d-ba79-47f6-905c-d75a0f613d10
              71e435ca-3d8c-43ab-bc1e-d072a335cbe6)
    bad = %w(agent 71e43dca-3d8c-41ab-bc1e-d072a335Xbe6)
    good_and_bad('wf_cloudintegration?', 'InvalidCloudIntegration',
                 good, bad)
  end

  def test_wf_alert?
    good = [1481553823153, '1481553823153']
    bad = [481553823153, '481553823153', [], {}, 'alert']
    good_and_bad('wf_alert?', 'InvalidAlert', good, bad)
  end

  def test_wf_dashboard?
    good = %w(my_dash S3 123)
    bad = ['a' * 260, 'A Dashboard Name', 'and_1_more!', {}, [], 1234]
    good_and_bad('wf_dashboard?', 'InvalidDashboard', good, bad)
  end

  def test_wf_event?
    good = %w(1493370839062:test1)
    bad = %w(1493370839062 1493370839062:test!)
    good_and_bad('wf_event?', 'InvalidEvent', good, bad)
  end

  def test_wf_version?
    good = [1, 2, 3, 4]
    bad = [-1, 'ab', [1]]
    good_and_bad('wf_version?', 'InvalidVersion', good, bad)
  end

  def test_wf_link_id?
    good = %w(lq6rPlSg2CFMSrg6)
    bad = %w(lq%rPlSg2CFMSrg6, lq6rPlSg2CFMSrg)
    good_and_bad('wf_link_id?', 'InvalidExternalLink', good, bad)
  end

  def test_wf_link_template?
    good = %w(http://link.xyz https://link.xyz/{{holder}})
    bad = %w(link.xyz https:/link.xyz/{{holder}})
    good_and_bad('wf_link_template?', 'InvalidLinkTemplate', good, bad)
  end

  def test_wf_maintenance_window?
    good = ['1493324005091', 1493324005091, Time.now.to_i * 1000]
    bad = [149332400509, '14933240050', Time.now, [], 'abcdef']
    good_and_bad('wf_maintenance_window?', 'InvalidMaintenanceWindow',
                 good, bad)
  end

  def test_wf_alert_severity?
    good = %w(info smoke warn severe)
    bad = %w(any thing else)
    good_and_bad('wf_alert_severity?', 'InvalidAlertSeverity', good, bad)
  end
end
