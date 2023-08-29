#!/usr/bin/env ruby
# frozen_string_literal: true

require_relative '../spec_helper'

# Unit tests for API token class
#
class WavefrontApiTokenTest < WavefrontTestBase
  def test_list
    assert_gets('/api/v2/apitoken') { wf.list }
  end

  def test_list_customer_tokens
    assert_gets('/api/v2/apitoken/customertokens') { wf.list_customer_tokens }
  end

  def test_describe_customer_token
    assert_invalid_id { wf.describe_customer_token(invalid_token_id) }

    assert_gets("/api/v2/apitoken/customertokens/#{token_id}") do
      wf.describe_customer_token(token_id)
    end
  end

  def test_create
    assert_posts('/api/v2/apitoken', 'null') { wf.create }
    assert_raises(ArgumentError) { wf.create('test') }
  end

  def test_rename
    assert_puts("/api/v2/apitoken/#{token_id}",
                tokenID: token_id, tokenName: 'token name') do
      wf.rename(token_id, 'token name')
    end

    assert_invalid_id { wf.rename(invalid_id, 'token name') }
    assert_raises(ArgumentError) { wf.rename }
    assert_raises(ArgumentError) { wf.rename(token_id) }
  end

  def test_sa_list
    assert_gets("/api/v2/apitoken/serviceaccount/#{id}") { wf.sa_list(id) }

    assert_raises(Wavefront::Exception::InvalidServiceAccountId) do
      wf.sa_list(invalid_id)
    end
  end

  def test_sa_create
    assert_posts("/api/v2/apitoken/serviceaccount/#{id}",
                 tokenName: 'token name') do
      wf.sa_create(id, 'token name')
    end

    assert_raises(Wavefront::Exception::InvalidServiceAccountId) do
      wf.sa_create(invalid_id, 'token name')
    end
  end

  def test_sa_rename
    assert_puts("/api/v2/apitoken/serviceaccount/#{id}/#{token_id}",
                tokenID: token_id, tokenName: 'new token name') do
      wf.sa_rename(id, token_id, 'new token name')
    end

    assert_invalid_id { wf.sa_rename(id, invalid_token_id, 'token name') }
    assert_raises(ArgumentError) { wf.sa_rename }
    assert_raises(ArgumentError) { wf.rename(id) }

    assert_raises(Wavefront::Exception::InvalidServiceAccountId) do
      wf.sa_rename(invalid_id, token_id, 'token name')
    end
  end

  def test_delete
    assert_deletes("/api/v2/apitoken/serviceaccount/#{id}/#{token_id}") do
      wf.sa_delete(id, token_id)
    end

    assert_invalid_id { wf.sa_delete(id, invalid_token_id) }

    assert_raises(Wavefront::Exception::InvalidServiceAccountId) do
      wf.sa_delete(invalid_id, token_id)
    end

    assert_raises(ArgumentError) { wf.sa_delete(id) }
    assert_raises(ArgumentError) { wf.sa_delete }
  end

  private

  def id
    'sa::tester'
  end

  def token_id
    '17db4cc1-65f6-40a8-a1fa-6fcae460c4bd'
  end

  def invalid_token_id
    '__bad__'
  end

  def invalid_id
    '__rubbish__'
  end

  def api_class
    'apitoken'
  end
end
