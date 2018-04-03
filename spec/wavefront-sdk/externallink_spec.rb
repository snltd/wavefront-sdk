#!/usr/bin/env ruby

require_relative '../spec_helper'

EXTERNAL_LINK = 'lq6rPlSg2CFMSrg6'.freeze
EXTERNAL_LINK_BODY = {
  name:        'test link',
  template:    'https://example.com/link/{{value}}',
  description: 'an imaginary link for unit testing purposes'
}.freeze

# rubocop:disable Style/MutableConstant
EXTERNAL_LINK_BODY_2 = {
  name:        'test link',
  template:    'https://example.com/link/{{value}}'
}
# rubocop:enable Style/MutableConstant

# Unit tests for ExternalLink class
#
class WavefrontExternalLinkTest < WavefrontTestBase
  def api_base
    'extlink'
  end

  def test_list
    should_work(:list, 10, '?offset=10&limit=100')
  end

  def test_describe
    should_work(:describe, EXTERNAL_LINK, EXTERNAL_LINK)
    should_be_invalid(:describe, 'abcdefg')
    assert_raises(ArgumentError) { wf.describe }
  end

  def test_create
    should_work(:create, EXTERNAL_LINK_BODY, '', :post,
                JSON_POST_HEADERS, EXTERNAL_LINK_BODY.to_json)

    should_work(:create, EXTERNAL_LINK_BODY_2, '', :post,
                JSON_POST_HEADERS, EXTERNAL_LINK_BODY_2
                .merge!(description: '').to_json)

    assert_raises(ArgumentError) { wf.create }
    assert_raises(ArgumentError) { wf.create('test') }
  end

  def test_delete
    should_work(:delete, EXTERNAL_LINK, EXTERNAL_LINK, :delete)
    should_be_invalid(:delete, 'abcdefg')
    assert_raises(ArgumentError) { wf.delete }
  end

  def test_update
    should_work(:update, [EXTERNAL_LINK, EXTERNAL_LINK_BODY, false],
                EXTERNAL_LINK, :put, JSON_POST_HEADERS,
                EXTERNAL_LINK_BODY.to_json)

    should_work(:update, [EXTERNAL_LINK, EXTERNAL_LINK_BODY_2, false],
                EXTERNAL_LINK, :put, JSON_POST_HEADERS,
                EXTERNAL_LINK_BODY_2.to_json)

    should_be_invalid(:update, ['abcde', EXTERNAL_LINK_BODY])
    assert_raises(ArgumentError) { wf.update }
    assert_raises(ArgumentError) { wf.update(EXTERNAL_LINK) }
  end
end
