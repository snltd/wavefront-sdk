#!/usr/bin/env ruby

require_relative '../spec_helper'
require_relative '../test_mixins/general'

# Unit tests for API token class
#
class WavefrontApiTokenTest < WavefrontTestBase
  include WavefrontTest::Delete

  def test_list
    assert_gets('/api/v2/apitoken') { wf.list }
  end

  def test_create
    assert_posts('/api/v2/apitoken', 'null') { wf.create }
    assert_raises(ArgumentError) { wf.create('test') }
  end

  def test_rename
    assert_puts("/api/v2/apitoken/#{id}",
                tokenID: id, tokenName: 'token name') do
      wf.rename(id, 'token name')
    end

    assert_invalid_id { wf.rename(invalid_id, 'token name') }
    assert_raises(ArgumentError) { wf.rename }
    assert_raises(ArgumentError) { wf.rename(id) }
  end

  private

  def id
    '17db4cc1-65f6-40a8-a1fa-6fcae460c4bd'
  end

  def invalid_id
    '__rubbish__'
  end

  def api_class
    'apitoken'
  end
end
