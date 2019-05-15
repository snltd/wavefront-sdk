#!/usr/bin/env ruby

require_relative '../spec_helper'

API_TOKEN_ID = '17db4cc1-65f6-40a8-a1fa-6fcae460c4bd'.freeze

# Unit tests for API token class
#
class WavefrontApiTokenTest < WavefrontTestBase
  def test_list
    should_work(:list, [], '')
  end

  def test_create
    should_work(:create, [], '', :post, JSON_POST_HEADERS, nil)
    assert_raises(ArgumentError) { wf.create('test') }
  end

  def test_delete
    should_work(:delete, API_TOKEN_ID, API_TOKEN_ID, :delete)
    should_be_invalid(:delete)
  end

  def test_rename
    should_work(:rename, [API_TOKEN_ID, 'token name'],
                API_TOKEN_ID, :put, JSON_POST_HEADERS,
                { tokenID: API_TOKEN_ID, tokenName: 'token name' }.to_json)
    should_be_invalid(:rename, ['!invalid token!', 'token name'])
    assert_raises(ArgumentError) { wf.rename }
  end
end
