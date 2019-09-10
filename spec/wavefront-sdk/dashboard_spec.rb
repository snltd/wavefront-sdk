#!/usr/bin/env ruby

require_relative '../spec_helper'
require_relative '../test_mixins/acl'
require_relative '../test_mixins/tag'
require_relative '../test_mixins/update_keys'
require_relative '../test_mixins/general'

# Unit tests for dashboard class
#
class WavefrontDashboardTest < WavefrontTestBase
  include WavefrontTest::Acl
  include WavefrontTest::Create
  include WavefrontTest::DeleteUndelete
  include WavefrontTest::Describe
  include WavefrontTest::History
  include WavefrontTest::List
  include WavefrontTest::Tag
  include WavefrontTest::Update
  include WavefrontTest::UpdateKeys

  def test_favorite
    assert_posts("/api/v2/dashboard/#{id}/favorite") { wf.favorite(id) }
    assert_invalid_id { wf.favorite(invalid_id) }
    assert_raises(ArgumentError) { wf.favorite }
    assert_posts("/api/v2/dashboard/#{id}/favorite") { wf.favourite(id) }
    assert_invalid_id { wf.favourite(invalid_id) }
    assert_raises(ArgumentError) { wf.favourite }
  end

  def test_unfavorite
    assert_posts("/api/v2/dashboard/#{id}/unfavorite") { wf.unfavorite(id) }
    assert_invalid_id { wf.unfavorite(invalid_id) }
    assert_raises(ArgumentError) { wf.unfavorite }

    assert_posts("/api/v2/dashboard/#{id}/unfavorite") do
      wf.unfavourite(id)
    end

    assert_invalid_id { wf.unfavourite(invalid_id) }
    assert_raises(ArgumentError) { wf.unfavourite }
  end

  private

  def api_class
    'dashboard'
  end

  def id
    'test_dashboard'
  end

  def invalid_id
    'a bad dashboard name'
  end

  def payload
    { name: 'SDK Dashboard test',
      id: 'sdk-test',
      description: 'dummy test dashboard',
      sections: [
        name: 'Section 1',
        rows: [
          { charts: [
            name: 'S1 Chart1',
            description: 'chart',
            sources: [
              { name: 'S1 C1 Source 1',
                query: 'ts("some.series")' }
            ]
          ] }
        ]
      ] }
  end
end
