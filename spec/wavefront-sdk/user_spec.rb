#!/usr/bin/env ruby

require_relative './spec_helper'

USER = 'user@example.com'.freeze
GROUP = 'agent_management'.freeze

USER_BODY = {
  emailAddress: USER,
  groups:       %w(browse)
}.freeze

# Unit tests for User class
#
class WavefrontUserTest < WavefrontTestBase
  def test_list
    should_work(:list, nil, '')
  end

  def test_describe
    should_work(:describe, USER, USER)
    should_be_invalid(:describe, 'abcdefg')
    assert_raises(ArgumentError) { wf.describe }
  end

  def test_create
    should_work(:create, [USER_BODY, true], '?sendEmail=true', :post,
                JSON_POST_HEADERS, USER_BODY.to_json)
    assert_raises(ArgumentError) { wf.create }
    assert_raises(ArgumentError) { wf.create('test') }
  end

  def test_delete
    should_work(:delete, USER, USER, :delete)
    should_be_invalid(:delete, 'abcdefg')
    assert_raises(ArgumentError) { wf.delete }
  end

  def test_grant
    should_work(:grant, [USER, GROUP], 'user%40example.com/grant',
                :post, JSON_POST_HEADERS.merge(
                  {'Content-Type': 'application/x-www-form-urlencoded'}),
                "group=#{GROUP}")
    should_be_invalid(:grant, ['abcde', GROUP])
    assert_raises(ArgumentError) { wf.grant }
  end

  def test_revoke
    should_work(:revoke, [USER, GROUP], 'user%40example.com/revoke',
                :post, JSON_POST_HEADERS.merge(
                  {'Content-Type': 'application/x-www-form-urlencoded'}),
                "group=#{GROUP}")
    should_be_invalid(:revoke, ['abcde', GROUP])
    assert_raises(ArgumentError) { wf.revoke }
  end
end
