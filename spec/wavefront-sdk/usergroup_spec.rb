#!/usr/bin/env ruby

require_relative '../spec_helper'

USERGROUP_ID = 'f8dc0c14-91a0-4ca9-8a2a-7d47f4db4672'.freeze
BAD_USERGROUP_ID = 'some_rubbish'.freeze

USERGROUP_BODY = { name:        'test group',
                   permissions: %w[alerts_management
                                   dashboard_management
                                   events_management] }.freeze

USER_LIST = %w[someone@somewhere.com other@elsewhere.net].freeze
BAD_USER_LIST = ['bad' * 500, ''].freeze

PERMISSION = 'alerts_management'.freeze

GROUP_LIST = %w[f8dc0c14-91a0-4ca9-8a2a-7d47f4db4672
                2659191e-aad4-4302-a94e-9667e1517127].freeze

BAD_GROUP_LIST = %w[some-nonsense more-nonsense].freeze

# Unit tests for WavefrontUserGroup
#
class WavefrontUserGroupTest < WavefrontTestBase
  def test_list
    should_work(:list, 10, '?offset=10&limit=100')
  end

  def test_create
    should_work(:create, USERGROUP_BODY, '', :post,
                JSON_POST_HEADERS, USERGROUP_BODY.to_json)
    assert_raises(ArgumentError) { wf.create }
    assert_raises(ArgumentError) { wf.create('test') }
  end

  def test_delete
    should_work(:delete, USERGROUP_ID, USERGROUP_ID, :delete)
    should_be_invalid(:delete)
  end

  def test_describe
    should_work(:describe, USERGROUP_ID, USERGROUP_ID)
    assert_raises(ArgumentError) { wf.describe }
  end

  def test_update
    should_work(:update, [USERGROUP_ID, USERGROUP_BODY, false],
                USERGROUP_ID, :put, JSON_POST_HEADERS,
                USERGROUP_BODY.to_json)
    should_be_invalid(:update, ['!some rubbish!', USERGROUP_BODY])
    assert_raises(ArgumentError) { wf.update }
  end

  def test_add_users_to_group
    should_work(:add_users_to_group, [USERGROUP_ID, USER_LIST],
                [USERGROUP_ID, :addUsers].uri_concat, :post)

    assert_raises(Wavefront::Exception::InvalidUserId) do
      wf.add_users_to_group(USERGROUP_ID, BAD_USER_LIST)
    end

    assert_raises(Wavefront::Exception::InvalidUserGroupId) do
      wf.add_users_to_group(BAD_USERGROUP_ID, USER_LIST)
    end
  end

  def test_remove_users_from_group
    should_work(:remove_users_from_group, [USERGROUP_ID, USER_LIST],
                [USERGROUP_ID, :removeUsers].uri_concat, :post)

    assert_raises(Wavefront::Exception::InvalidUserId) do
      wf.remove_users_from_group(USERGROUP_ID, BAD_USER_LIST)
    end

    assert_raises(Wavefront::Exception::InvalidUserGroupId) do
      wf.remove_users_from_group(BAD_USERGROUP_ID, USER_LIST)
    end
  end

  def test_grant
    should_work(:grant, [PERMISSION, GROUP_LIST],
                [:grant, PERMISSION].uri_concat, :post)

    assert_raises(Wavefront::Exception::InvalidUserGroupId) do
      wf.grant(PERMISSION, BAD_GROUP_LIST)
    end
  end

  def test_revoke
    should_work(:revoke, [PERMISSION, GROUP_LIST],
                [:revoke, PERMISSION].uri_concat, :post)

    assert_raises(Wavefront::Exception::InvalidUserGroupId) do
      wf.revoke(PERMISSION, BAD_GROUP_LIST)
    end
  end
end
