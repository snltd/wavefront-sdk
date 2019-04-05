#!/usr/bin/env ruby

require 'date'
require 'minitest/autorun'
require_relative '../spec_helper'
require_relative '../../lib/wavefront-sdk/defs/constants'
require_relative '../../lib/wavefront-sdk/validators'

# Validator tests, obviously. Happy now Rubocop?
#
class WavefrontValidatorsTest < MiniTest::Test
  include Wavefront::Validators

  def good_and_bad(method, exception, good, bad)
    ex = Object.const_get("Wavefront::Exception::#{exception}")

    good.each { |m| assert send(method, m) }
    bad.each { |m| assert_raises(ex) { send(method, m) } }
  end

  def test_wf_metric_name?
    good = ['a.l33t.metric_path-passes', 'NO.NEED.TO.SHOUT',
            '"slash/allowed_in_quotes"', '"comma,allowed_in_quotes"',
            "#{DELTA}deltas.must.pass", "\"#{DELTA}quoted.delta\""]
    bad  = ['metric.is.(>_<)', { key: 'val' }, 'no/slash', 'no,comma',
            [], "not.a.#{DELTA}"]
    good_and_bad('wf_metric_name?', 'InvalidMetricName', good, bad)
  end

  def test_wf_string?
    good = ['string', 'valid string', 'valid, valid string.',
            'valid-string', ' VALID_string']
    bad  = ['a' * 1024, '(>_<)', { key: 'val' }, [], 123_456]
    good_and_bad('wf_string?', 'InvalidString', good, bad)
  end

  def test_wf_name?
    good = %w[name name123]
    bad  = ['a' * 1024, '(>_<)', { key: 'val' }, [], 123_456, '']
    good_and_bad('wf_name?', 'InvalidName', good, bad)
  end

  def test_wf_source_id?
    good = ['validsource1', 'valid-source', 'valid_source',
            'valid.source', 'Valid_Source', 'a' * 1023, '123456']
    bad  = ['a' * 1024, '(>_<)', { key: 'val' }, [], 123_456]
    good_and_bad('wf_source_id?', 'InvalidSourceId', good, bad)
  end

  def test_wf_value?
    good = [0, 123, -10, 1.23456789, 1.23e04]
    bad = ['1', 'abc', '0', {}, []]
    good_and_bad('wf_value?', 'InvalidMetricValue', good, bad)
  end

  # rubocop:disable Style/DateTime
  def test_wf_ts?
    good = [Time.now, Date.today, DateTime.now]
    bad  = ['2017-03-25 23:52:22 +0000', 1_490_485_946,
            '#<Date: 2017-03-25 ((2457838j,0s,0n),+0s,2299161j)>']
    good_and_bad('wf_ts?', 'InvalidTimestamp', good, bad)
  end
  # rubocop:enable Style/DateTime

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
    good = ['abc', 'abc123', '__tag__', 'my:tag', %w[abc abc123]]
    bad = ['^^^', Time.now, 'bad tag', ['abc', '!BAD!']]
    good_and_bad('wf_tag?', 'InvalidTag', good, bad)
  end

  def test_wf_point_tags?
    good = [{},
            { tag1: 'val1', tag2: 'val2' },
            { tag1: 'val 1', tag2: 'val 2' },
            { TAG1: 'val 1', tag2: 'val 2' },
            { 'TAG-1': 'val 1', tag2: 'val 2' },
            { 'TAG_1': 'val 1', tag_2: 'val 2' },
            { 'TAG.1': 'val 1', tag_2: 'val 2' },
            { 'TAG-1': 'val 1', tag2: 'val 2' },
            { tag1: '(>_<)', tag2: '^_^' }]
    bad  = ['key=value',
            { tag: 'badval\\' },
            { 'tag 1': 'val1', 'tag 2': 'val2' },
            { 'TAG*1': 'val 1', tag_2: 'val 2' },
            { '(>_<)': 'val1', '^_^': 'val2' },
            { tag: nil },
            { tag: false },
            { tag1: 'v' * 255 },
            { 'k' * 255 => 'val1' },
            { 'k' * 130 => 'v' * 130 }]
    good_and_bad('wf_point_tags?', 'InvalidTag', good, bad)
  end

  def test_wf_proxy_id?
    good = %w[fd248f53-378e-4fbe-bbd3-efabace8d724
              917102d1-a10e-497b-ba63-95058f98d4fb]
    bad = %w[proxy 17102d1-a10e-497b-ba63-95058f98d4fb]
    good_and_bad('wf_proxy_id?', 'InvalidProxyId', good, bad)
  end

  def test_wf_cloudintegration_id?
    good = %w[3b56f61d-ba79-47f6-905c-d75a0f613d10
              71e435ca-3d8c-43ab-bc1e-d072a335cbe6]
    bad = %w[proxy 71e43dca-3d8c-41ab-bc1e-d072a335Xbe6]
    good_and_bad('wf_cloudintegration_id?', 'InvalidCloudIntegrationId',
                 good, bad)
  end

  def test_wf_alert_id?
    good = [1_481_553_823_153, '1481553823153']
    bad = [481_553_823_153, '481553823153', [], {}, 'alert']
    good_and_bad('wf_alert_id?', 'InvalidAlertId', good, bad)
  end

  def test_wf_dashboard_id?
    good = %w[my_dash my-dashboard S3 123]
    bad = ['a' * 260, 'A Dashboard Name', 'and_1_more!', {}, [], 1234]
    good_and_bad('wf_dashboard_id?', 'InvalidDashboardId', good, bad)
  end

  def test_wf_event_id?
    good = %w[1493370839062:test1]
    bad = %w[1493370839062 1493370839062test!]
    good_and_bad('wf_event_id?', 'InvalidEventId', good, bad)
  end

  def test_wf_version?
    good = [1, 2, 3, 4, '10']
    bad = [-1, 'ab', [1]]
    good_and_bad('wf_version?', 'InvalidVersion', good, bad)
  end

  def test_wf_derivedmetric_id?
    good = %w[1529926075038 1529936045036]
    bad = %w[metricid 152992607503 15299260750384 lq%rPlSg2CFMSrg6
             lq6rPlSg2CFMSrg]
    good_and_bad('wf_derivedmetric_id?', 'InvalidDerivedMetricId',
                 good, bad)
  end

  def test_wf_link_id?
    good = %w[lq6rPlSg2CFMSrg6]
    bad = %w[lq%rPlSg2CFMSrg6 lq6rPlSg2CFMSrg]
    good_and_bad('wf_link_id?', 'InvalidExternalLinkId', good, bad)
  end

  def test_wf_link_template?
    good = %w[http://link.xyz https://link.xyz/{{holder}}]
    bad = %w[link.xyz https:/link.xyz/{{holder}}]
    good_and_bad('wf_link_template?', 'InvalidLinkTemplate', good, bad)
  end

  def test_wf_maintenance_window_id?
    good = ['1493324005091', 1_493_324_005_091, Time.now.to_i * 1000]
    bad = [149_332_400_509, '14933240050', Time.now, [], 'abcdef']
    good_and_bad('wf_maintenance_window_id?', 'InvalidMaintenanceWindowId',
                 good, bad)
  end

  def test_wf_message_id?
    good = %w[CLUSTER::IHjNaHM9]
    bad = %w[4OfsEM8RcvkM7n 4OfsEM8Rcvk-7nw]
    good_and_bad('wf_message_id?', 'InvalidMessageId', good, bad)
  end

  def test_wf_alert_severity?
    good = %w[INFO SMOKE WARN SEVERE]
    bad = %w[any THING else]
    good_and_bad('wf_alert_severity?', 'InvalidAlertSeverity', good, bad)
  end

  def test_wf_granularity?
    good = ['d', 'h', 'm', 's', :d, :h, :m, :s]
    bad = [1, 'a', 'day', :hour]
    good_and_bad('wf_granularity?', 'InvalidGranularity', good, bad)
  end

  def test_wf_savedsearch_id?
    good = %w[e2hLH2FR]
    bad = %w[e2hLH2F e2hLH2FRz]
    good_and_bad('wf_savedsearch_id?', 'InvalidSavedSearchId', good, bad)
  end

  def test_wf_savedsearch_entity?
    good = %w[EVENT MAINTENANCE_WINDOW DASHBOARD ALERT]
    bad = %w[1 a day hour]
    good_and_bad('wf_savedsearch_entity?',
                 'InvalidSavedSearchEntity', good, bad)
  end

  def test_wf_user_id?
    good = %w[Some.User@example.com general99+specific@somewhere.net
              someone@somewhere.com a user user-name]
    bad = ['', [], {}, 'a' * 1000]
    good_and_bad('wf_user_id?', 'InvalidUserId', good, bad)
  end

  def test_wf_usergroup_id?
    good = %w[2f17beb4-51b1-4362-b19f-098e3e4ab44d
              42622766-52c2-4a8b-8070-b6f4623028c1]
    bad = %w[word Name 42622766-52c2-4a8b-8070-b6f4623028c
             z2622766-52c2-4a8b-8070-b6f4623028c1]
    good_and_bad('wf_usergroup_id?', 'InvalidUserGroupId', good, bad)
  end

  def test_wf_webhook_id?
    good = %w[4OfsEM8RcvkM7nwG]
    bad = %w[4OfsEM8RcvkM7n 4OfsEM8Rcvk-7nw]
    good_and_bad('wf_webhook_id?', 'InvalidWebhookId', good, bad)
  end

  def test_wf_point?
    good = { path: 'test.metric', value: 123_456, ts: Time.now.to_i,
             source: 'testhost', tags: { t1: 'v 1', t2: 'v2' } }

    assert(wf_point?(good))

    %w[tags source ts].each do |t|
      p = good.dup
      p.delete(t)
      assert(wf_point?(p))
    end

    bad = good.dup
    bad[:path] = '!n\/@1!d_metric'

    assert_raises(Wavefront::Exception::InvalidMetricName) do
      wf_point?(bad)
    end

    bad = good.dup
    bad[:value] = 'abc'

    assert_raises(Wavefront::Exception::InvalidMetricValue) do
      wf_point?(bad)
    end

    bad = good.dup
    bad[:ts] = 'abc'

    assert_raises(Wavefront::Exception::InvalidTimestamp) do
      wf_point?(bad)
    end

    bad = good.dup
    bad[:source] = '<------>'

    assert_raises(Wavefront::Exception::InvalidSourceId) do
      wf_point?(bad)
    end

    bad = good.dup
    bad[:tags] = { '<------>': 45 }

    assert_raises(Wavefront::Exception::InvalidTag) do
      wf_point?(bad)
    end
  end

  def test_wf_disitribution?
    value = [[4, 10], [6, 11], [15, 1e5]]
    good = { path: 'test.metric', value: value, ts: Time.now.to_i,
             source: 'testhost', tags: { t1: 'v 1', t2: 'v2' } }

    assert(wf_distribution?(good))

    %w[tags source ts].each do |t|
      p = good.dup
      p.delete(t)
      assert(wf_distribution?(p))
    end

    bad = good.dup
    bad[:path] = '!n\/@1!d_metric'

    assert_raises(Wavefront::Exception::InvalidMetricName) do
      wf_distribution?(bad)
    end

    bad = good.dup
    bad[:value] = [[1.2, 5]]

    assert_raises(Wavefront::Exception::InvalidDistributionCount) do
      wf_distribution?(bad)
    end

    bad = good.dup
    bad[:value] = [[2, 'abc']]

    assert_raises(Wavefront::Exception::InvalidMetricValue) do
      wf_distribution?(bad)
    end

    bad = good.dup
    bad[:ts] = 'abc'

    assert_raises(Wavefront::Exception::InvalidTimestamp) do
      wf_distribution?(bad)
    end

    bad = good.dup
    bad[:source] = '<------>'

    assert_raises(Wavefront::Exception::InvalidSourceId) do
      wf_distribution?(bad)
    end

    bad = good.dup
    bad[:tags] = { '<------>': 45 }

    assert_raises(Wavefront::Exception::InvalidTag) do
      wf_distribution?(bad)
    end
  end

  def test_notificant_id
    good = %w[CHTo47HvsPzSaGhh]
    bad = ['CTo47HvsPzSaGhh', [], {}, nil, 'bad id']
    good_and_bad('wf_notificant_id?', 'InvalidNotificantId', good, bad)
  end

  def test_integration_id
    good = %w[aws tutorial elasticsearch cassandra go]
    bad = ['CTo47HvsPzSaGhh', [], {}, nil, 'bad id']
    good_and_bad('wf_integration_id?', 'InvalidIntegrationId', good, bad)
  end

  def test_distribution_interval
    good = %i[m h d]
    bad = ['m', [], {}, nil, 'bad id', :x, 'p']
    good_and_bad('wf_distribution_interval?',
                 'InvalidDistributionInterval', good, bad)
  end
end
