#!/usr/bin/env ruby
# frozen_string_literal: true

require_relative '../spec_helper'
require_relative '../test_mixins/general'

# Unit tests for ServiceAccount class
#
class WavefrontServiceAccountTest < WavefrontTestBase
  # include WavefrontTest::Create
  # include WavefrontTest::Describe
  # include WavefrontTest::Update

  # def test_list
  # assert_gets('/api/v2/account/serviceaccount') { wf.list }
  # end

  def test_activate
    assert_posts("/api/v2/account/serviceaccount/#{id}/activate", nil,
                 :json) do
      wf.activate(id)
    end

    assert_invalid_id { wf.activate(invalid_id) }
    assert_raises(ArgumentError) { wf.activate }
  end

  def test_deactivate
    assert_posts("/api/v2/account/serviceaccount/#{id}/deactivate", nil,
                 :json) do
      wf.deactivate(id)
    end

    assert_invalid_id { wf.deactivate(invalid_id) }
    assert_raises(ArgumentError) { wf.deactivate }
  end

  private

  def api_class
    'account/serviceaccount'
  end

  def id
    'sa::tester'
  end

  def invalid_id
    'bad_id'
  end

  def payload
    { identifier: id,
      description: 'some info',
      tokens: [
        'f8dc0c14-91a0-4ca9-8a2a-7d47f4db4672'
      ],
      userGroups: [
        '2659191e-aad4-4302-a94e-9667e1517127'
      ],
      groups: [
        'agent_management'
      ] }
  end
end
