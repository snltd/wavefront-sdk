#!/usr/bin/env ruby

require_relative '../spec_helper'
require_relative '../test_mixins/general'

# Unit tests for notificant class
#
class WavefrontNotificantTest < WavefrontTestBase
  include WavefrontTest::List
  include WavefrontTest::Delete
  include WavefrontTest::Describe

  def test_test
    assert_posts("/api/v2/notificant/test/#{id}") { wf.test(id) }
    assert_invalid_id { wf.test(invalid_id) }
  end

  private

  def api_class
    'notificant'
  end

  def id
    '8Bl5l7wxtdGindxk'
  end

  def invalid_id
    '---rubbish---'
  end
end
