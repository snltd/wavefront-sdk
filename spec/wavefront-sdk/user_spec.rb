#!/usr/bin/env ruby

require_relative '../spec_helper'
require_relative '../test_mixins/general'

# Unit tests for User class
#
class WavefrontUserTest < WavefrontTestBase
  attr_reader :users, :groups, :permission

  include WavefrontTest::Delete
  include WavefrontTest::Describe
  include WavefrontTest::Update

  def test_list
    assert_gets('/api/v2/user') { wf.list }
  end

  def test_create
    assert_posts('/api/v2/user?sendEmail=true', payload) do
      wf.create(payload, true)
    end

    assert_posts('/api/v2/user?sendEmail=false', payload) do
      wf.create(payload)
    end

    assert_raises(ArgumentError) { wf.create }
    assert_raises(ArgumentError) { wf.create('test') }
  end

  def test_add_groups_to_user
    assert_posts("/api/v2/user/#{id}/addUserGroups", groups.to_json) do
      wf.add_groups_to_user(id, groups)
    end

    assert_invalid_id { wf.add_groups_to_user(invalid_id, groups) }
  end

  def test_remove_groups_from_user
    assert_posts("/api/v2/user/#{id}/removeUserGroups", groups.to_json) do
      wf.remove_groups_from_user(id, groups)
    end

    assert_invalid_id { wf.remove_groups_from_user(invalid_id, groups) }
  end

  def test_grant
    assert_posts("/api/v2/user/#{id}/grant", { group: permission },
                 :form) do
      wf.grant(id, permission)
    end

    assert_invalid_id { wf.grant(invalid_id, permission) }
    assert_raises(ArgumentError) { wf.grant }
  end

  def test_revoke
    assert_posts("/api/v2/user/#{id}/revoke", { group: permission },
                 :form) do
      wf.revoke(id, permission)
    end

    assert_invalid_id { wf.revoke(invalid_id, permission) }
    assert_raises(ArgumentError) { wf.revoke }
  end

  def test_delete_users
    assert_posts('/api/v2/user/deleteUsers', users.to_json) do
      wf.delete_users(users)
    end

    assert_invalid_id { wf.delete_users([invalid_id]) }
    assert_raises(ArgumentError) { wf.delete_users(id) }
  end

  def test_grant_permission
    assert_posts("/api/v2/user/grant/#{permission}", users.to_json) do
      wf.grant_permission(permission, users)
    end

    assert_invalid_id { wf.grant_permission(permission, [invalid_id]) }
    assert_raises(ArgumentError) { wf.grant }
  end

  def test_revoke_permission
    assert_posts("/api/v2/user/revoke/#{permission}", users.to_json) do
      wf.revoke_permission(permission, users)
    end

    assert_invalid_id { wf.revoke_permission(permission, [invalid_id]) }
    assert_raises(ArgumentError) { wf.grant }
  end

  def test_invite
    assert_posts('/api/v2/user/invite', [payload].to_json) do
      wf.invite([payload])
    end

    assert_raises(ArgumentError) { wf.invite }
    assert_raises(ArgumentError) { wf.invite('test') }
  end

  def test_response_shim
    (RESOURCE_DIR + 'user_responses').each_child do |input|
      # Ugly hack for the 202 in the 'create' file
      status = input.basename.to_s == 'create.json' ? 202 : 200
      shimmed = wf.response_shim(IO.read(input), status)
      assert_instance_of(String, shimmed)

      ret_obj = JSON.parse(shimmed, symbolize_names: true)
      assert_instance_of(Hash, ret_obj)
      assert_equal(%i[response status], ret_obj.keys.sort)

      ret_status = ret_obj[:status]
      assert_instance_of(Hash, ret_status)
      assert_equal(%i[result message code], ret_status.keys)

      ret_resp = ret_obj[:response]
      assert_instance_of(Hash, ret_resp)
      assert ret_resp.key?(:items)
      assert_instance_of(Array, ret_resp[:items])
    end
  end

  def setup_fixtures
    @users = %w[user@example.com other@elsewhere.com]
    @groups = %w[f8dc0c14-91a0-4ca9-8a2a-7d47f4db4672
                 2659191e-aad4-4302-a94e-9667e1517127]
    @permission = 'agent_management'
  end

  private

  def api_class
    'user'
  end

  def id
    'user@example.com'
  end

  def invalid_id
    'user' * 500
  end

  def payload
    { emailAddress: id, groups: %w[browse] }
  end
end
