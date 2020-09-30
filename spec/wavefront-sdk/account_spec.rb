#!/usr/bin/env ruby
# frozen_string_literal: true

require_relative '../spec_helper'
require_relative '../test_mixins/general'

# Unit tests for Account class
#
class WavefrontAccountTest < WavefrontTestBase
  include WavefrontTest::List
  include WavefrontTest::Delete
  include WavefrontTest::Describe

  def test_add_roles
    assert_posts("/api/v2/account/#{id}/addRoles", roles.to_json) do
      wf.add_roles(id, roles)
    end

    assert_invalid_id { wf.add_roles(invalid_id, roles) }

    assert_raises(Wavefront::Exception::InvalidRoleId) do
      wf.add_roles(id, invalid_role)
    end
  end

  def test_add_user_groups
    assert_posts("/api/v2/account/#{id}/addUserGroups", groups.to_json) do
      wf.add_user_groups(id, groups)
    end

    assert_invalid_id { wf.add_user_groups(invalid_id, groups) }
  end

  def test_business_functions
    assert_gets("/api/v2/account/#{id}/businessFunctions") do
      wf.business_functions(id)
    end

    assert_raises(ArgumentError) { wf.business_functions }
  end

  def test_grant_to_single_user
    assert_posts("/api/v2/account/#{id}/grant/#{permission}") do
      wf.grant(id, permission)
    end
  end

  def test_grant_to_multiple_users
    assert_posts("/api/v2/account/grant/#{permission}", id_list.to_json) do
      wf.grant(id_list, permission)
    end

    assert_raises(Wavefront::Exception::InvalidRoleId) do
      wf.remove_roles(id, invalid_role)
    end
  end

  def test_remove_roles
    assert_posts("/api/v2/account/#{id}/removeRoles", roles.to_json) do
      wf.remove_roles(id, roles)
    end

    assert_invalid_id { wf.remove_roles(invalid_id, roles) }

    assert_raises(Wavefront::Exception::InvalidRoleId) do
      wf.remove_roles(id, invalid_role)
    end
  end

  def test_remove_user_groups
    assert_posts("/api/v2/account/#{id}/removeUserGroups", groups.to_json) do
      wf.remove_user_groups(id, groups)
    end

    assert_invalid_id { wf.remove_user_groups(invalid_id, groups) }

    assert_raises(Wavefront::Exception::InvalidUserGroupId) do
      wf.remove_user_groups(id, invalid_group)
    end
  end

  def test_revoke_from_single_user
    assert_posts("/api/v2/account/#{id}/revoke/#{permission}") do
      wf.revoke(id, permission)
    end

    assert_invalid_id { wf.revoke(invalid_id, permission) }

    assert_raises(Wavefront::Exception::InvalidPermission) do
      wf.revoke(id, invalid_permission)
    end
  end

  def test_revoke_from_multiple_users
    assert_posts("/api/v2/account/revoke/#{permission}", id_list.to_json) do
      wf.revoke(id_list, permission)
    end
  end

  def test_delete_accounts
    assert_posts('/api/v2/account/deleteAccounts', id_list.to_json) do
      wf.delete_accounts(id_list)
    end

    assert_invalid_id { wf.delete_accounts([invalid_id]) }
  end

  def test_add_ingestion_policy
    assert_posts('/api/v2/account/addingestionpolicy',
                 { ingestionPolicyId: policy_id,
                   accounts: id_list }.to_json) do
      wf.add_ingestion_policy(policy_id, id_list)
    end

    assert_raises Wavefront::Exception::InvalidIngestionPolicyId do
      wf.add_ingestion_policy(invalid_policy_id, id_list)
    end

    assert_invalid_id { wf.add_ingestion_policy(policy_id, [invalid_id]) }
  end

  def test_remove_ingestion_policy
    assert_posts('/api/v2/account/removeingestionpolicies',
                 { ingestionPolicyId: policy_id,
                   accounts: id_list }.to_json) do
      wf.remove_ingestion_policy(policy_id, id_list)
    end

    assert_raises Wavefront::Exception::InvalidIngestionPolicyId do
      wf.add_ingestion_policy(invalid_policy_id, id_list)
    end

    assert_invalid_id { wf.add_ingestion_policy(policy_id, [invalid_id]) }
  end

  def test_user_list
    assert_gets('/api/v2/account/user?offset=0&limit=100') do
      wf.user_list
    end

    assert_gets('/api/v2/account/user?offset=10&limit=50') do
      wf.user_list(10, 50)
    end
  end

  def test_user_describe
    assert_gets("/api/v2/account/user/#{id}") { wf.user_describe(id) }

    assert_raises(Wavefront::Exception::InvalidUserId) do
      wf.user_describe(invalid_id)
    end

    assert_raises(ArgumentError) { wf.user_describe }
  end

  def test_user_create
    assert_posts('/api/v2/account/user', payload.to_json) do
      wf.user_create(payload)
    end

    assert_raises(ArgumentError) { wf.user_create }
    assert_raises(ArgumentError) { wf.user_create('test') }
  end

  def test_user_invite
    assert_posts('/api/v2/account/user/invite', [payload].to_json) do
      wf.user_invite([payload])
    end

    assert_raises(ArgumentError) { wf.user_invite }
    assert_raises(ArgumentError) { wf.user_invite('test') }
  end

  def test_validate_accounts
    assert_posts('/api/v2/account/validateAccounts', id_list.to_json) do
      wf.validate_accounts(id_list)
    end

    assert_raises(ArgumentError) { wf.validate_accounts }
  end

  private

  def api_class
    'account'
  end

  def id
    'sa::tester'
  end

  def invalid_id
    'bad_id' * 1000
  end

  def groups
    %w[f8dc0c14-91a0-4ca9-8a2a-7d47f4db4672
       2659191e-aad4-4302-a94e-9667e1517127]
  end

  def roles
    %w[f8dc0c14-91a0-4ca9-8a2a-7d47f4db1234
       2659191e-aad4-4302-a94e-9667e1515678]
  end

  def invalid_role
    %w[bad_role]
  end

  def invalid_group
    %w[bad_group]
  end

  def id_list
    %w[sa:test user@example.com]
  end

  def invalid_permission
    'some_nonsense_permission_i_made_up'
  end

  def permission
    'agent_management'
  end

  def policy_id
    'testpolicy-1579537565010'
  end

  def invalid_policy_id
    'badpolicy'
  end

  def payload
    { emailAddress: id,
      groups: %w[browse] }
  end
end
