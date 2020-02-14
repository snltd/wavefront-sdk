#!/usr/bin/env ruby
# frozen_string_literal: true

require_relative '../spec_helper'
require_relative '../test_mixins/general'
require_relative '../test_mixins/tag'

# Unit tests for MonitoredCluster class
#
class WavefrontMonitoredClusterTest < WavefrontTestBase
  include WavefrontTest::Create
  include WavefrontTest::Delete
  include WavefrontTest::Describe
  include WavefrontTest::List
  include WavefrontTest::Update
  include WavefrontTest::Tag

  def test_merge
    assert_puts("/api/v2/monitoredcluster/merge/#{id}/#{id2}", nil, :json) do
      wf.merge(id, id2)
    end

    assert_invalid_id { wf.merge(id, invalid_id) }
  end

  private

  def api_class
    'monitoredcluster'
  end

  def id
    'k8s-sample'
  end

  def id2
    'eks-cluster'
  end

  def invalid_id
    '!!!!'
  end

  def payload
    { id: 'k8s-sample',
      name: 'Sample cluster',
      platform: 'EKS',
      version: '1.2',
      additionalTags: {
        region: 'us-west-2',
        az: 'testing'
      },
      tags: %w[alertTag1] }
  end
end
