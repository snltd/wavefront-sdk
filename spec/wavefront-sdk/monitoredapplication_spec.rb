#!/usr/bin/env ruby
# frozen_string_literal: true

require_relative '../spec_helper'
require_relative '../test_mixins/general'

# Unit tests for Webhook class
#
class WavefrontWebhookTest < WavefrontTestBase
  include WavefrontTest::Describe
  include WavefrontTest::List
  include WavefrontTest::Update

  private

  def api_class
    'monitoredapplication'
  end

  def id
    'beachshirts'
  end

  def invalid_id
    '+-+-+-+'
  end

  def payload
    {
      application: 'beachshirts',
      satisfiedLatencyMillis: 100_000,
      hidden: 'false'
    }
  end
end
