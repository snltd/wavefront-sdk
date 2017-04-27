#!/usr/bin/env ruby

require_relative './spec_helper'

EXTERNAL_LINK_BODY = {
  name:        'test link',
  template:    'https://example.com/link/{{value}}',
  description: 'an imaginary link for unit testing purposes'
}

EXTERNAL_LINK_BODY_2 = {
  name:        'test link',
  template:    'https://example.com/link/{{value}}',
}

EXTERNAL_LINK_BODY_3 = {
  template:    'https://example.com/link/{{value}}',
}

# Unit tests for ExternalLink class
#
class WavefrontExternalLinkTest < WavefrontTestBase
  def test_list
    should_work('list', 10, '?offset=10&limit=100')
  end

  def test_describe
    should_work('describe', EXTERNAL_LINK, EXTERNAL_LINK)
    should_be_invalid('describe', 'abcdefg')
    assert_raises(ArgumentError) { wf.describe }
  end

  def test_create
    headers ={'Content-Type': 'application/json',
              'Accept': 'application/json'}

    should_work('create', EXTERNAL_LINK_BODY.values, '',
                :post, headers, EXTERNAL_LINK_BODY.to_json)

    should_work('create', EXTERNAL_LINK_BODY_2.values, '', :post,
                headers, EXTERNAL_LINK_BODY_2
                .merge!(description: '').to_json)

    assert_raises(ArgumentError) { wf.create }
    assert_raises(ArgumentError) { wf.create('test') }
    assert_raises(Wavefront::Exception::InvalidLinkTemplate) {
      wf.create('test link', 'invalid')
    }
  end

  def test_delete
    should_work('delete', EXTERNAL_LINK, EXTERNAL_LINK, :delete)
    should_be_invalid('delete', 'abcdefg')
    assert_raises(ArgumentError) { wf.delete }
  end

  def test_update
    headers ={'Content-Type': 'application/json',
              'Accept': 'application/json'}

    should_work('update', [EXTERNAL_LINK, EXTERNAL_LINK_BODY],
                EXTERNAL_LINK, :put, headers,
                EXTERNAL_LINK_BODY.to_json)

    should_work('update', [EXTERNAL_LINK, EXTERNAL_LINK_BODY_2],
                EXTERNAL_LINK, :put, headers,
                EXTERNAL_LINK_BODY_2.to_json )

    should_work('update', [EXTERNAL_LINK, EXTERNAL_LINK_BODY_3],
                EXTERNAL_LINK, :put, headers,
                EXTERNAL_LINK_BODY_3.to_json )

    should_be_invalid('update', ['abcde', EXTERNAL_LINK_BODY])
    assert_raises(ArgumentError) { wf.update }
    assert_raises(ArgumentError) { wf.update(EXTERNAL_LINK) }
    assert_raises(Wavefront::Exception::InvalidLinkTemplate) {
      wf.update(EXTERNAL_LINK, { template: 'invalid' }) }
  end
end
