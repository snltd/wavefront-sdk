#!/usr/bin/env ruby
# frozen_string_literal: true

require_relative '../spec_helper'

# Unit tests for Search class
#
class WavefrontSearchTest < WavefrontTestBase
  def test_raw_search
    assert_posts('/api/v2/search/agent', payload) do
      wf.raw_search('agent', payload)
    end

    assert_posts('/api/v2/search/agent/deleted', payload) do
      wf.raw_search('agent', payload, true)
    end

    assert_raises(ArgumentError) { wf.raw_search('ALERT', 'junk') }
    assert_raises(ArgumentError) { wf.raw_search }
  end

  def test_raw_facet_search
    assert_posts('/api/v2/search/agent/facets', payload) do
      wf.raw_facet_search('agent', payload)
    end

    assert_posts('/api/v2/search/agent/deleted/facets', payload) do
      wf.raw_facet_search('agent', payload, true)
    end

    assert_posts('/api/v2/search/agent/Tags', payload) do
      wf.raw_facet_search('agent', payload, false, 'Tags')
    end

    assert_posts('/api/v2/search/agent/deleted/Tags', payload) do
      wf.raw_facet_search('agent', payload, true, 'Tags')
    end

    assert_raises(ArgumentError) { wf.raw_facet_search }
    assert_raises(ArgumentError) { wf.raw_facet_search('ALERT', 'junk') }
  end

  def test_body
    q = [{ key: 'k1', value: 'v1', matchingMethod: 'EXACT' },
         { key: 'k2', value: 'v2', matchingMethod: 'CONTAINS' }]

    r1 = wf.body(q, {})

    assert_equal({ limit: 10,
                   offset: 0,
                   query: [
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

  private

  def payload
    { limit: 10,
      offset: 0,
      query: [{ key: 'name',
                value: 'Wavefront',
                matchingMethod: 'CONTAINS' }],
      sort: { field: 'string',
              ascending: true } }
  end
end
