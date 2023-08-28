#!/usr/bin/env ruby
# frozen_string_literal: true

require_relative '../spec_helper'
require_relative '../test_mixins/general'

# Unit tests for AccessPolicy class
#
class WavefrontAccessPolicyTest < WavefrontTestBase
  def test_describe
    assert_gets('/api/v2/accesspolicy') { wf.describe }
  end

  def test_update
    assert_puts('/api/v2/accesspolicy', payload.to_json) do
      wf.update(payload)
    end
  end

  def test_validate
    assert_gets('/api/v2/accesspolicy/validate?ip=1.2.3.4') do
      wf.validate('1.2.3.4')
    end
  end

  private

  def api_class
    'accesspolicy'
  end

  def payload
    {
      status: {
        result: 'OK',
        message: 'string',
        code: 0
      },
      response: {
        customer: 'string',
        lastUpdatedMs: 0,
        policyRules: [
          {
            name: 'string',
            description: 'string',
            subnet: 'string',
            action: 'ALLOW'
          }
        ]
      }
    }
  end
end
