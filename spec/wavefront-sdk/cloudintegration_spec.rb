#!/usr/bin/env ruby
# frozen_string_literal: true

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

  def test_create_aws_external_id
    assert_posts('/api/v2/cloudintegration/awsExternalId', nil, :json) do
      wf.create_aws_external_id
    end
  end

  def test_delete_aws_external_id
    assert_deletes("/api/v2/cloudintegration/awsExternalId/#{external_id}") do
      wf.delete_aws_external_id(external_id)
    end

    assert_raises(Wavefront::Exception::InvalidAwsExternalId) do
      wf.delete_aws_external_id(invalid_external_id)
    end

    assert_raises(ArgumentError) { wf.delete_aws_external_id }
  end

  def test_confirm_aws_external_id
    assert_gets("/api/v2/cloudintegration/awsExternalId/#{external_id}") do
      wf.confirm_aws_external_id(external_id)
    end

    assert_raises(Wavefront::Exception::InvalidAwsExternalId) do
      wf.confirm_aws_external_id(invalid_external_id)
    end

    assert_raises(ArgumentError) { wf.confirm_aws_external_id }
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
          roleArn: 'arn:aws:iam::<accountid>:role/<rolename>',
          externalId: 'wave123'
        }
      },
      metricFilterRegex: '^aws.(sqs|ec2|ebs|elb).*$' }
  end

  def api_class
    'cloudintegration'
  end

  def external_id
    'HqOM4mru5svd3uFp'
  end

  def invalid_external_id
    '__nonsense__'
  end
end
