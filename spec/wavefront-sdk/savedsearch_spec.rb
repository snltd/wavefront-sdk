#!/usr/bin/env ruby

require_relative '../spec_helper'

SAVED_SEARCH = 'e2hLH2FR'.freeze
SAVED_SEARCH_BODY = {
  query: {
    foo: '{"searchTerms":[{"type":"freetext","value":"foo"}]}'
  },
  entityType: 'DASHBOARD'
}.freeze

# Unit tests for SavedSearch class
#
class WavefrontSavedSearchTest < WavefrontTestBase
  def test_list
    should_work(:list, [], '?offset=0&limit=100')
    should_work(:list, 10, '?offset=10&limit=100')
    should_work(:list, [20, 250], '?offset=20&limit=250')
  end

  def test_create
    should_work(:create, SAVED_SEARCH_BODY, '', :post, JSON_POST_HEADERS,
                SAVED_SEARCH_BODY.to_json)
    assert_raises(ArgumentError) { wf.create }
    assert_raises(ArgumentError) { wf.create('test') }
  end

  def test_delete
    should_work(:delete, SAVED_SEARCH, SAVED_SEARCH, :delete)
    should_be_invalid(:delete)
  end

  def test_describe
    should_work(:describe, SAVED_SEARCH, SAVED_SEARCH)
    should_be_invalid(:describe)
  end

  def test_update
    should_work(:update, [SAVED_SEARCH, SAVED_SEARCH_BODY],
                SAVED_SEARCH, :put, JSON_POST_HEADERS,
                SAVED_SEARCH_BODY.to_json)
    should_be_invalid(:update, ['abcde', SAVED_SEARCH_BODY])
    assert_raises(ArgumentError) { wf.update }
  end

  def test_entity
    %w[ALERT EVENT MAINTENANCE_WINDOW DASHBOARD SOURCE AGENT].each do |e|
      should_work(:entity, e, "type/#{e}?offset=0&limit=100")
      should_work(:entity, [e, 20], "type/#{e}?offset=20&limit=100")
      should_work(:entity, [e, 20, 50], "type/#{e}?offset=20&limit=50")
    end
  end
end
