#!/usr/bin/env ruby
# frozen_string_literal: true

require_relative '../spec_helper'
require_relative '../test_mixins/general'

# Unit tests for Wavefront::Role
#
class WavefrontRoleTest < WavefrontTestBase
  include WavefrontTest::Create
  include WavefrontTest::Delete
  include WavefrontTest::Describe
  include WavefrontTest::List
  include WavefrontTest::Update

  def test_grant
    assert_posts("/api/v2/role/grant/#{permission}", roles.to_json) do
      wf.grant(permission, roles)
    end

    assert_raises(Wavefront::Exception::InvalidRoleId) do
      wf.grant(permission, [invalid_id])
    end

    assert_raises(Wavefront::Exception::InvalidPermission) do
      wf.grant('made_up_permission', roles)
    end
  end

  def test_revoke
    assert_posts("/api/v2/role/revoke/#{permission}", roles.to_json) do
      wf.revoke(permission, roles)
    end

    assert_raises(Wavefront::Exception::InvalidRoleId) do
      wf.revoke(permission, [invalid_id])
    end

    assert_raises(Wavefront::Exception::InvalidPermission) do
      wf.revoke('made_up_permission', roles)
    end
  end

  def test_add_assignees
    assert_posts("/api/v2/role/#{id}/addAssignees", assignees.to_json) do
      wf.add_assignees(id, assignees)
    end

    assert_raises(Wavefront::Exception::InvalidRoleId) do
      wf.add_assignees(invalid_id, assignees)
    end
  end

  def test_remove_assignees
    assert_posts("/api/v2/role/#{id}/removeAssignees", assignees.to_json) do
      wf.remove_assignees(id, assignees)
    end

    assert_raises(Wavefront::Exception::InvalidRoleId) do
      wf.remove_assignees(invalid_id, assignees)
    end
  end

  private

  def api_class
    :role
  end

  def id
    'f8dc0c14-91a0-4ca9-8a2a-7d47f4db4672'
  end

  def roles
    %w[f8dc0c14-91a0-4ca9-8a2a-7d47f4db4672
       2659191e-aad4-4302-a94e-9667e1517127]
  end

  def assignees
    roles.append('sa::test')
  end

  def invalid_id
    '__BAD_ID__'
  end

  def payload
    { name: 'test role',
      permissions: %w[alerts_management events_management],
      description: 'dummy role for unit tests' }
  end

  def permission
    'alerts_management'
  end
end
