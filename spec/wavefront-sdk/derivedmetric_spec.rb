#!/usr/bin/env ruby
# frozen_string_literal: true

require_relative '../spec_helper'
require_relative '../test_mixins/general'
require_relative '../test_mixins/tag'

# Unit tests for derived metric class
#
class WavefrontDerivedMetricTest < WavefrontTestBase
  include WavefrontTest::Create
  include WavefrontTest::DeleteUndelete
  include WavefrontTest::Describe
  include WavefrontTest::History
  include WavefrontTest::List
  include WavefrontTest::Tag
  include WavefrontTest::Update

  private

  def id
    '1529926075038'
  end

  def invalid_id
    '! invalid derived metric !'
  end

  def payload
    { minutes: 5,
      name: 'test_1',
      id: id,
      query: 'aliasMetric(ts("test.metric"), "derived.test_1")',
      tags: { customerTags: ['test'] },
      includeObsoleteMetrics: false,
      processRateMinutes: 1 }
  end

  def api_class
    'derivedmetric'
  end
end
