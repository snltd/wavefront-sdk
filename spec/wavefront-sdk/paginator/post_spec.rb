#!/usr/bin/env ruby

require 'json'
require_relative '../../spec_helper'
require_relative '../../../lib/wavefront-sdk/paginator/post'

# Stub for ApiCaller class
#
class FakeApiCaller
  def respond(_args); end
end

# Stub for connection object
#
class FakeConn
  def get(*args); end
end

# Test POST pagination
#
class WavefrontPaginatorPostTest < MiniTest::Test
  attr_reader :wf, :apicaller, :conn

  def setup
    @apicaller = FakeApiCaller.new
    @conn      = FakeConn.new
    args = [nil, { offset: 3, limit: :lazy }]
    @wf = Wavefront::Paginator::Post.new(apicaller, conn, :post, args)
  end

  def test_body_as
    bo1 = [nil, { offset: 3, limit: 'lazy' }]
    bs1 = [nil, '{"offset":3,"limit":"lazy"}']

    bo2 = ['thing', { offset: 3, limit: 'lazy', a: 2 }, { c: 3 }]
    bs2 = ['thing', '{"offset":3,"limit":"lazy","a":2}', { c: 3 }]

    assert_equal(bo1, wf.body_as(Hash, bo1))
    assert_equal(bo1, wf.body_as(Hash, bs1))
    assert_equal(bs1, wf.body_as(String, bs1))
    assert_equal(bo1, wf.body_as(Hash, bs1))
    assert_equal([], wf.body_as(Hash, 'plain string'))

    assert_equal(bo2, wf.body_as(Hash, bo2))
    assert_equal(bo2, wf.body_as(Hash, bs2))
    assert_equal(bs2, wf.body_as(String, bs2))
    assert_equal(bo2, wf.body_as(Hash, bs2))
  end
end
