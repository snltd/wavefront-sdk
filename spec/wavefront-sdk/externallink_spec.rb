#!/usr/bin/env ruby

require_relative '../spec_helper'
require_relative '../test_mixins/general'

# Unit tests for ExternalLink class
#
class WavefrontExternalLinkTest < WavefrontTestBase
  include WavefrontTest::List
  include WavefrontTest::Create
  include WavefrontTest::Delete
  include WavefrontTest::Describe
  include WavefrontTest::Update

  private

  def id
    'lq6rPlSg2CFMSrg6'
  end

  def invalid_id
    '__rubbish_id__'
  end

  def payload
    [{ name:        'test link',
       template:    'https://example.com/link/{{value}}',
       description: 'an imaginary link for unit testing purposes' },
     { name:        'test link',
       template:    'https://example.com/link/{{value}}' }]
  end

  def api_class
    'extlink'
  end
end
