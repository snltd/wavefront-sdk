#!/usr/bin/env ruby

require_relative '../spec_helper'

INTEGRATION = 'tester'.freeze

# Unit tests for Integration class
#
class WavefrontIntegrationTest < WavefrontTestBase
  def test_list
    should_work(:list, 10, '?offset=10&limit=100')
  end

  def test_install
    should_work(:install, INTEGRATION, ["#{INTEGRATION}/install", nil],
                :post, POST_HEADERS)
    should_be_invalid(:install)
    assert_raises(ArgumentError) { wf.install }
  end

  def test_uninstall
    should_work(:uninstall, INTEGRATION, ["#{INTEGRATION}/uninstall", nil],
                :post, POST_HEADERS)
    should_be_invalid(:uninstall)
    assert_raises(ArgumentError) { wf.uninstall }
  end

  def test_describe
    should_work(:describe, INTEGRATION, INTEGRATION)
    should_be_invalid(:describe)
    assert_raises(ArgumentError) { wf.describe }
  end

  def test_status
    should_work(:status, INTEGRATION, "#{INTEGRATION}/status")
    should_be_invalid(:status)
    assert_raises(ArgumentError) { wf.status }
  end

  def test_manifests
    should_work(:manifests, nil, 'manifests')
  end

  def test_statuses
    should_work(:statuses, nil, 'status')
  end
end
