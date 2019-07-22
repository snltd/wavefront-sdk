#!/usr/bin/env ruby

require_relative '../spec_helper'
require_relative '../test_mixins/general'

# Unit tests for CloudIntegration class
#
class WavefrontCloudIntegrationTest < WavefrontTestBase
  include WavefrontTest::List
  include WavefrontTest::Create
  include WavefrontTest::Describe
  include WavefrontTest::Update
  include WavefrontTest::DeleteUndelete

  def test_update
    assert_puts("/api/v2/cloudintegration/#{id}", payload) do
      wf.update(id, payload)
    end

    assert_invalid_id { wf.update(invalid_id, payload) }
    assert_raises(ArgumentError) { wf.update }
  end

  def test_enable
    assert_posts("/api/v2/cloudintegration/#{id}/enable") { wf.enable(id) }
    assert_invalid_id { wf.enable(invalid_id) }
    assert_raises(ArgumentError) { wf.enable }
  end

  def test_disable
    assert_posts("/api/v2/cloudintegration/#{id}/disable") do
      wf.disable(id)
    end

    assert_invalid_id { wf.disable(invalid_id) }
    assert_raises(ArgumentError) { wf.disable }
  end

  private

  def id
    '3b56f61d-1a79-46f6-905c-d75a0f613d10'
  end

  def invalid_id
    '__rubbish__'
  end

  def payload
    { name: 'SDK test Cloudwatch Integration',
      service: 'CLOUDWATCH',
      cloudWatch: {
        baseCredentials: {
          roleArn:    'arn:aws:iam::<accountid>:role/<rolename>',
          externalId: 'wave123'
        }
      },
      metricFilterRegex: '^aws.(sqs|ec2|ebs|elb).*$' }
  end

  def api_class
    'cloudintegration'
  end
end
