#!/usr/bin/env ruby

require_relative '../spec_helper'

SETTINGS_BODY = { showQuerybuilderByDefault: true,
                  hideTSWhenQuerybuilderShown: true }.freeze

# Unit tests for Settings class
#
class WavefrontSettingsTest < WavefrontTestBase
  def api_base
    'customer'
  end

  def test_permissions
    should_work(:permissions, nil, 'permissions')
  end

  def test_preferences
    should_work(:preferences, nil, 'preferences')
  end

  def test_update_preferences
    should_work(:update_preferences, SETTINGS_BODY, 'preferences',
                :post, JSON_POST_HEADERS, SETTINGS_BODY.to_json)
  end

  def test_default_user_groups
    should_work(:default_user_groups, nil, 'preferences/defaultUserGroups')
  end
end
