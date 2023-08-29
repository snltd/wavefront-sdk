#!/usr/bin/env ruby
# frozen_string_literal: true

require_relative '../spec_helper'
require_relative '../test_mixins/general'

# Unit tests for IngestionPolicy class
#
class WavefrontIngestionPolicyTest < WavefrontTestBase
  include WavefrontTest::List
  include WavefrontTest::Describe
  include WavefrontTest::Update
  include WavefrontTest::Delete
  include WavefrontTest::History

  def test_revert
    assert_posts("/api/v2/usage/ingestionpolicy/#{id}/revert/5", nil, :json) do
      wf.revert(id, 5)
    end

    assert_raises(Wavefront::Exception::InvalidVersion) { wf.revert(id, 'v5') }

    assert_invalid_id { wf.revert(invalid_id, 5) }
  end

  private

  def payload
    { sampledUserAccounts: ['string'],
      userAccountCount: 0,
      sampledServiceAccounts: [
        'string'
      ],
      serviceAccountCount: 0,
      name: 'string',
      id: 'string',
      description: 'string',
      customer: 'string',
      lastUpdatedMs: 0,
      lastUpdatedAccountId: 'string' }
  end

  def api_class
    'usage/ingestionpolicy'
  end

  def id
    'test-ingestion-policy-1579538401492'
  end

  def invalid_id
    'bad_id'
  end
end
