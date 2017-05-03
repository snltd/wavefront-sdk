#!/usr/bin/env ruby

require_relative './spec_helper'

CLOUD = '3b56f61d-1a79-46f6-905c-d75a0f613d10'.freeze
CLOUD_BODY = {
  name: 'SDK test Cloudwatch Integration',
  service: 'CLOUDWATCH',
  cloudWatch: {
    baseCredentials: {
      roleArn:    'arn:aws:iam::<accountid>:role/<rolename>',
      externalId: 'wave123'
    }
  },
  metricFilterRegex: '^aws.(sqs|ec2|ebs|elb).*$'
}.freeze

# Unit tests for CloudIntegration class
#
class WavefrontCloudIntegrationTest < WavefrontTestBase
  def test_list
    should_work(:list, 10, '?offset=10&limit=100')
  end

  def test_create
    should_work(:create, CLOUD_BODY, '', :post, JSON_POST_HEADERS,
                CLOUD_BODY.to_json)
    assert_raises(ArgumentError) { wf.create }
    assert_raises(ArgumentError) { wf.create('test') }
  end

  def test_delete
    should_work(:delete, CLOUD, CLOUD, :delete)
    should_be_invalid(:delete)
  end

  def test_describe
    should_work(:describe, CLOUD, CLOUD)
    should_be_invalid(:describe)
  end

  def test_update
    should_work(:update, [CLOUD, CLOUD_BODY], CLOUD, :put,
                JSON_POST_HEADERS, CLOUD_BODY.to_json)
    should_be_invalid(:update, ['abcde', CLOUD_BODY])
    assert_raises(ArgumentError) { wf.update }
  end

  def test_undelete
    should_work(:undelete, CLOUD, ["#{CLOUD}/undelete", nil], :post,
                POST_HEADERS)
    should_be_invalid(:undelete)
  end
end
