#!/usr/bin/env ruby

require_relative '../spec_helper'

USER = 'user@example.com'.freeze
BAD_USER = ('user' * 500).freeze
PERMISSION = 'agent_management'.freeze

USER_BODY = { emailAddress: USER, groups: %w[browse] }.freeze

USERGROUP_LIST = %w[f8dc0c14-91a0-4ca9-8a2a-7d47f4db4672
                    2659191e-aad4-4302-a94e-9667e1517127].freeze

USER_LIST = %w[user@example.com other@elsewhere.com].freeze

# Unit tests for User class
#
class WavefrontUserTest < WavefrontTestBase
  def test_list
    should_work(:list, nil, '')
  end

  def test_create
    should_work(:create, [USER_BODY, true], '?sendEmail=true', :post,
                JSON_POST_HEADERS, USER_BODY.to_json)
    assert_raises(ArgumentError) { wf.create }
    assert_raises(ArgumentError) { wf.create('test') }
  end

  def test_delete
    should_work(:delete, USER, USER, :delete)
    should_be_invalid(:delete, BAD_USER)
    assert_raises(ArgumentError) { wf.delete }
  end

  def test_describe
    should_work(:describe, USER, USER)
    should_be_invalid(:describe, BAD_USER)
    assert_raises(ArgumentError) { wf.describe }
  end

  def test_update
    should_work(:update, [USER, USER_BODY, false], USER, :put,
                JSON_POST_HEADERS, USER_BODY.to_json)
    should_be_invalid(:update, [BAD_USER, USER_BODY])
    assert_raises(ArgumentError) { wf.update }
  end

  def test_add_groups_to_user
    should_work(:add_groups_to_user, [USER, USERGROUP_LIST],
                [USER, :addUserGroups].uri_concat, :post,
                JSON_POST_HEADERS, USERGROUP_LIST.to_json)

    assert_raises(Wavefront::Exception::InvalidUserId) do
      wf.add_groups_to_user(BAD_USER, USERGROUP_LIST)
    end
  end

  def test_remove_groups_from_user
    should_work(:remove_groups_from_user, [USER, USERGROUP_LIST],
                [USER, :removeUserGroups].uri_concat, :post,
                JSON_POST_HEADERS, USERGROUP_LIST.to_json)

    assert_raises(Wavefront::Exception::InvalidUserId) do
      wf.remove_groups_from_user(BAD_USER, USERGROUP_LIST)
    end
  end

  def test_grant
    should_work(:grant, [USER, PERMISSION], 'user%40example.com/grant',
                :post, JSON_POST_HEADERS.merge(
                         'Content-Type': 'application/x-www-form-urlencoded'
                ),
                "group=#{PERMISSION}")
    should_be_invalid(:grant, [BAD_USER, PERMISSION])
    assert_raises(ArgumentError) { wf.grant }
  end

  def test_revoke
    should_work(:revoke, [USER, PERMISSION], 'user%40example.com/revoke',
                :post, JSON_POST_HEADERS.merge(
                         'Content-Type': 'application/x-www-form-urlencoded'
                ),
                "group=#{PERMISSION}")
    should_be_invalid(:revoke, [BAD_USER, PERMISSION])
    assert_raises(ArgumentError) { wf.revoke }
  end

  def test_delete_users
    should_work(:delete_users, [[USER, 'other@example.com']],
                'deleteUsers', :post, JSON_POST_HEADERS,
                [USER, 'other@example.com'].to_json)

    assert_raises(Wavefront::Exception::InvalidUserId) do
      wf.delete_users([BAD_USER])
    end

    assert_raises(ArgumentError) { wf.delete_users('a@b.com') }
  end

  def test_grant_permission
    should_work(:grant_permission, [PERMISSION, USER_LIST],
                [:grant, PERMISSION].uri_concat, :post,
                JSON_POST_HEADERS, USER_LIST.to_json)
    should_be_invalid(:grant, [BAD_USER, PERMISSION])
    assert_raises(ArgumentError) { wf.grant }
  end

  def test_revoke_permission
    should_work(:revoke_permission, [PERMISSION, USER_LIST],
                [:revoke, PERMISSION].uri_concat, :post,
                JSON_POST_HEADERS, USER_LIST.to_json)
    should_be_invalid(:revoke, [BAD_USER, PERMISSION])
    assert_raises(ArgumentError) { wf.grant }
  end

  def test_invite
    should_work(:invite, [[USER_BODY]], 'invite', :post,
                JSON_POST_HEADERS, [USER_BODY].to_json)
    assert_raises(ArgumentError) { wf.invite }
    assert_raises(ArgumentError) { wf.invite('test') }
  end
end
