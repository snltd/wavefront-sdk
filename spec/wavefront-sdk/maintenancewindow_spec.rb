#!/usr/bin/env ruby

require_relative '../spec_helper'
require_relative '../test_mixins/general'

# Unit tests for MaintenanceWindow class
#
class WavefrontMaintenanceWindowTest < WavefrontTestBase
  include WavefrontTest::Create
  include WavefrontTest::Delete
  include WavefrontTest::Describe
  include WavefrontTest::List
  include WavefrontTest::Update

  private

  def api_class
    'maintenancewindow'
  end

  def id
    '1493324005091'
  end

  def payload
    { reason:   'testing SDK',
      title:    'test window',
      start:    Time.now.to_i,
      end:      Time.now.to_i + 600,
      tags:     %w[testtag1 testtag2],
      hostTags: %w[hosttag1 hosttag2] }
  end
end
