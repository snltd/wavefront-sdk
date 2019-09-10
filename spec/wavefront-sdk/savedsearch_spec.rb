#!/usr/bin/env ruby

require_relative '../spec_helper'
require_relative '../test_mixins/general'

# Unit tests for SavedSearch class
#
class WavefrontSavedSearchTest < WavefrontTestBase
  include WavefrontTest::Create
  include WavefrontTest::Delete
  include WavefrontTest::Describe
  include WavefrontTest::List
  include WavefrontTest::Update

  def test_update
    assert_puts("/api/v2/savedsearch/#{id}", payload) do
      wf.update(id, payload)
    end

    assert_invalid_id { wf.update(invalid_id, payload) }
    assert_raises(ArgumentError) { wf.update }
  end

  def test_entity
    %w[ALERT EVENT MAINTENANCE_WINDOW DASHBOARD SOURCE AGENT].each do |e|
      assert_gets("/api/v2/savedsearch/type/#{e}?offset=0&limit=100") do
        wf.entity(e)
      end

      assert_gets("/api/v2/savedsearch/type/#{e}?offset=20&limit=100") do
        wf.entity(e, 20)
      end

      assert_gets("/api/v2/savedsearch/type/#{e}?offset=10&limit=50") do
        wf.entity(e, 10, 50)
      end
    end
  end

  private

  def api_class
    'savedsearch'
  end

  def id
    'e2hLH2FR'
  end

  def invalid_id
    'some bad id or other'
  end

  def payload
    { query: {
      foo: '{"searchTerms":[{"type":"freetext","value":"foo"}]}'
    },
      entityType: 'DASHBOARD' }
  end
end
