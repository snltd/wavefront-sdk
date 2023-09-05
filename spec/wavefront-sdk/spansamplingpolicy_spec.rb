#!/usr/bin/env ruby
# frozen_string_literal: true

require_relative '../spec_helper'
require_relative '../test_mixins/general'

# Unit tests for SpanSamplingPolicy class
#
class WavefrontSpanSamplingPolicyTest < WavefrontTestBase
  include WavefrontTest::Create
  include WavefrontTest::DeleteUndelete
  include WavefrontTest::Describe
  include WavefrontTest::History
  include WavefrontTest::List
  include WavefrontTest::Update

  def test_deleted
    assert_gets('/api/v2/spansamplingpolicy/deleted') { wf.deleted }
  end

  private

  # used by the things we #include
  #
  def api_class
    'spansamplingpolicy'
  end

  def id
    'test_policy'
  end

  def invalid_id
    {}
  end

  def payload
    {
      name: 'Test',
      id: 'test',
      active: false,
      expression: "{{sourceName}}='localhost'",
      description: 'test description',
      samplingPercent: 100
    }
  end
end
