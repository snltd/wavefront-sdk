#!/usr/bin/env ruby
# frozen_string_literal: true

require_relative '../spec_helper'

# Unit tests for Settings class
#
class WavefrontSettingsTest < WavefrontTestBase
  def test_permissions
    assert_gets('/api/v2/customer/permissions') do
      wf.permissions
    end
  end

  def test_preferences
    assert_gets('/api/v2/customer/preferences') do
      wf.preferences
    end
  end

  def test_update_preferences
    assert_posts('/api/v2/customer/preferences', payload) do
      wf.update_preferences(payload)
    end
  end

  def test_default_user_groups
    assert_gets('/api/v2/customer/preferences/defaultUserGroups') do
      wf.default_user_groups
    end
  end

  private

  def payload
    { showQuerybuilderByDefault: true, hideTSWhenQuerybuilderShown: true }
  end
end
