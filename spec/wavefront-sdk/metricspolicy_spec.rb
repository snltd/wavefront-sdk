#!/usr/bin/env ruby
# frozen_string_literal: true

require_relative '../spec_helper'
require_relative '../test_mixins/general'

# Unit tests for MetricsPolicy class
#
class WavefrontMetricsPolicyTest < WavefrontTestBase
  def test_describe
    assert_gets('/api/v2/metricspolicy') { wf.describe }

    assert_gets('/api/v2/metricspolicy/history/5') { wf.describe(5) }

    assert_raises(Wavefront::Exception::InvalidVersion) do
      wf.describe('v5')
    end
  end

  def test_history
    assert_gets('/api/v2/metricspolicy?offset=10&limit=100') do
      wf.history(10)
    end

    assert_gets('/api/v2/metricspolicy?offset=12&limit=34') do
      wf.history(12, 34)
    end
  end

  def test_revert
    assert_posts('/api/v2/metricspolicy/revert/5') do
      wf.revert(5)
    end

    assert_raises(Wavefront::Exception::InvalidVersion) do
      wf.revert('v5')
    end
  end

  def test_update
    assert_puts('/api/v2/metricspolicy', payload.to_json) do
      wf.update(payload)
    end
  end

  private

  def api_class
    'metricspolicy'
  end

  def id
    'a7d2e651-cec1-4154-a5e8-1946f57ef5b3'
  end

  def invalid_id
    '+-+-+-+'
  end

  def payload
    {
      policyRules: [
        {
          name: 'Policy rule1 name',
          description: 'Policy rule1 description',
          prefixes: ['revenue.*'],
          tags: [
            {
              key: 'sensitive',
              value: 'false'
            },
            {
              key: 'source',
              value: 'app1'
            }
          ],
          tagsAnded: 'true',
          accessType: 'ALLOW',
          accounts: %w[accountId1 accountId2],
          userGroups: ['userGroupId1'],
          roles: ['roleId']
        },
        {
          name: 'Policy rule2 name',
          description: 'Policy rule2 description',
          prefixes: ['revenue.*'],
          accessType: 'BLOCK',
          accounts: ['accountId3'],
          userGroups: ['userGroupId1']
        }
      ]
    }
  end
end
