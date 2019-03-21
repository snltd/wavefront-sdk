#!/usr/bin/env ruby

require_relative '../spec_helper'

SEARCH_BODY = {
  limit: 10,
  offset: 0,
  query: [{ key:            'name',
            value:          'Wavefront',
            matchingMethod: 'CONTAINS' }],
  sort: { field:     'string',
          ascending: true }
}.freeze

# Unit tests for Search class
#
class WavefrontSearchTest < WavefrontTestBase
  def test_search
    should_work(:raw_search, ['agent', SEARCH_BODY], 'agent', :post,
                JSON_POST_HEADERS, SEARCH_BODY.to_json)
    should_work(:raw_search, ['agent', SEARCH_BODY, true], 'agent/deleted',
                :post, JSON_POST_HEADERS, SEARCH_BODY.to_json)
    assert_raises(ArgumentError) { wf.raw_search }
    assert_raises(ArgumentError) { wf.raw_search('ALERT', 'junk') }
  end

  def test_facet_search
    should_work(:raw_facet_search, ['agent', SEARCH_BODY],
                'agent/facets', :post, JSON_POST_HEADERS,
                SEARCH_BODY.to_json)

    should_work(:raw_facet_search, ['agent', SEARCH_BODY, true],
                'agent/deleted/facets', :post, JSON_POST_HEADERS,
                SEARCH_BODY.to_json)

    should_work(:raw_facet_search, ['agent', SEARCH_BODY, false, 'Tags'],
                'agent/Tags', :post, JSON_POST_HEADERS,
                SEARCH_BODY.to_json)

    should_work(:raw_facet_search, ['agent', SEARCH_BODY, true, 'Tags'],
                'agent/deleted/Tags', :post, JSON_POST_HEADERS,
                SEARCH_BODY.to_json)

    assert_raises(ArgumentError) { wf.raw_facet_search }
    assert_raises(ArgumentError) { wf.raw_facet_search('ALERT', 'junk') }
  end

  def test_body
    q = [{ key: 'k1', value: 'v1', matchingMethod: 'EXACT' },
         { key: 'k2', value: 'v2', matchingMethod: 'CONTAINS' }]

    r1 = wf.body(q, {})

    assert_equal({ limit: 10,
                   offset: 0,
                   query:  [
                     { key: 'k1', value: 'v1', matchingMethod: 'EXACT' },
                     { key: 'k2', value: 'v2', matchingMethod: 'CONTAINS' }
                   ],
                   sort: { field: 'k1', ascending: true } },
                 r1)

    r2 = wf.body(q, limit: 50)
    assert_equal(50, r2[:limit])
    assert_equal(0, r2[:offset])

    r3 = wf.body([], {})

    assert_equal({ limit: 10, offset: 0 }, r3)
    assert_equal(0, r3[:offset])

    r4 = wf.body(q, sort_field: :mykey)
    assert_equal({ field: :mykey, ascending: true }, r4[:sort])
  end
end
