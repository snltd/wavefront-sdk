#!/usr/bin/env ruby
# frozen_string_literal: true

require_relative '../spec_helper'
require_relative '../test_mixins/general'

# Unit tests for WavefrontUserGroup
#
class WavefrontUserGroupTest < WavefrontTestBase
  attr_reader :users, :groups, :permission, :invalid_groups, :invalid_users

  include WavefrontTest::Create
  include WavefrontTest::Delete
  include WavefrontTest::Describe
  include WavefrontTest::List
  include WavefrontTest::Update

  def test_add_users_to_group
    assert_posts("/api/v2/usergroup/#{id}/addUsers", users.to_json) do
      wf.add_users_to_group(id, users)
    end

    assert_raises(Wavefront::Exception::InvalidUserId) do
      wf.add_users_to_group(id, invalid_users)
    end

    assert_invalid_id { wf.add_users_to_group(invalid_id, users) }
  end

  def test_remove_users_from_group
    assert_posts("/api/v2/usergroup/#{id}/removeUsers", users.to_json) do
      wf.remove_users_from_group(id, users)
    end

    assert_raises(Wavefront::Exception::InvalidUserId) do
      wf.remove_users_from_group(id, invalid_users)
    end

    assert_invalid_id { wf.remove_users_from_group(invalid_id, users) }
  end

  def setup_fixtures
    @permission = 'alerts_management'
    @invalid_groups = %w[some-nonsense more-nonsense]
    @groups = %w[f8dc0c14-91a0-4ca9-8a2a-7d47f4db4672
                 2659191e-aad4-4302-a94e-9667e1517127]
    @users = %w[someone@somewhere.com other@elsewhere.net]
    @invalid_users = ['bad' * 500, '']
  end

  private

  def api_class
    'usergroup'
  end

  def id
    'f8dc0c14-91a0-4ca9-8a2a-7d47f4db4672'
  end

  def invalid_id
    'this is not what you call a group'
  end

  def payload
    { name: 'test group',
      permissions: %w[alerts_management dashboard_management
                      events_management] }
  end
end
