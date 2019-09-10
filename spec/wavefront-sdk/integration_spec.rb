#!/usr/bin/env ruby

require_relative '../spec_helper'
require_relative '../test_mixins/general'

# Unit tests for Integration class
#
class WavefrontIntegrationTest < WavefrontTestBase
  include WavefrontTest::Describe
  include WavefrontTest::InstallUninstall
  include WavefrontTest::List

  def test_install_all_alerts
    assert_posts("/api/v2/integration/#{id}/install-all-alerts") do
      wf.install_all_alerts(id)
    end

    assert_invalid_id { wf.install_all_alerts(invalid_id) }
    assert_raises(ArgumentError) { wf.install_all_alerts }
  end

  def test_uninstall_all_alerts
    assert_posts("/api/v2/integration/#{id}/uninstall-all-alerts") do
      wf.uninstall_all_alerts(id)
    end

    assert_invalid_id { wf.uninstall_all_alerts(invalid_id) }
    assert_raises(ArgumentError) { wf.uninstall_all_alerts }
  end

  def test_status
    assert_gets("/api/v2/integration/#{id}/status") { wf.status(id) }
    assert_invalid_id { wf.status(invalid_id) }
    assert_raises(ArgumentError) { wf.status }
  end

  def test_installed
    assert_gets('/api/v2/integration/installed') { wf.installed }
  end

  def test_manifests
    assert_gets('/api/v2/integration/manifests') { wf.manifests }
  end

  def test_statuses
    assert_gets('/api/v2/integration/status') { wf.statuses }
  end

  private

  def api_class
    'integration'
  end

  def id
    'tester'
  end

  def invalid_id
    'very bad id'
  end
end
