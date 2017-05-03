#!/usr/bin/env ruby

require_relative './spec_helper'

SEARCH_BODY = {
  limit: 10,
  offset: 0,
  query: [{ key:            'name',
            value:          'Wavefront',
            matchingMethod: 'CONTAINS'}],
  sort: { field:     'string',
          ascending: true }
}.freeze

# Unit tests for Search class
#
class WavefrontSearchTest < WavefrontTestBase
  def test_search
    should_work(:search, ['agent', SEARCH_BODY], 'agent', :post,
                JSON_POST_HEADERS, SEARCH_BODY.to_json)
    should_work(:search, ['agent', SEARCH_BODY, true], 'agent/deleted',
                :post, JSON_POST_HEADERS, SEARCH_BODY.to_json)
    assert_raises(ArgumentError) { wf.search }
    assert_raises(ArgumentError) { wf.search('ALERT', 'junk') }
  end

  def test_facet_search
    should_work(:facet_search, ['agent', SEARCH_BODY],
                'agent/facets', :post, JSON_POST_HEADERS,
                SEARCH_BODY.to_json)

    should_work(:facet_search, ['agent', SEARCH_BODY, true],
                'agent/deleted/facets', :post, JSON_POST_HEADERS,
                SEARCH_BODY.to_json)

    should_work(:facet_search, ['agent', SEARCH_BODY, false, 'Tags'],
                'agent/Tags', :post, JSON_POST_HEADERS,
                SEARCH_BODY.to_json)

    should_work(:facet_search, ['agent', SEARCH_BODY, true, 'Tags'],
                'agent/deleted/Tags', :post, JSON_POST_HEADERS,
                SEARCH_BODY.to_json)

    assert_raises(ArgumentError) { wf.facet_search }
    assert_raises(ArgumentError) { wf.facet_search('ALERT', 'junk') }
  end
end
