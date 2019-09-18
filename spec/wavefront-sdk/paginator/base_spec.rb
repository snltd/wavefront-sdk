#!/usr/bin/env ruby
# frozen_string_literal: true

require_relative '../../spec_helper'
require_relative '../../../lib/wavefront-sdk/paginator/base'

# Stub for ApiCaller class
#
class FakeApiCaller
  def respond(args); end
end

# Stub for connection object
#
class FakeConn
  def get(*args); end
end

# Paginator tests
#
class WavefrontPaginatorBaseTest < MiniTest::Test
  attr_reader :wf, :apicaller, :conn

  def setup
    @apicaller = FakeApiCaller.new
    @conn      = FakeConn.new
    args = [nil, { offset: 3, limit: :lazy }]

    @wf = Wavefront::Paginator::Base.new(apicaller, conn, :get, args)
  end

  def test_limit_and_offset
    assert_equal({ limit: nil, offset: nil }, wf.limit_and_offset([]))
    assert_equal({ limit: nil, offset: 10 },
                 wf.limit_and_offset([nil, { offset: 10 }]))
    assert_equal({ limit: 15, offset: nil },
                 wf.limit_and_offset([nil, { limit: 15 }]))
    assert_equal({ limit: 95, offset: 0 },
                 wf.limit_and_offset([nil, { limit: 95, offset: 0 }]))
    assert_equal({ limit: 95, offset: 0 },
                 wf.limit_and_offset([{ a: 1 }, { limit: 95, offset: 0 }]))
    assert_equal({ limit: 33, offset: 6 },
                 wf.limit_and_offset([{ offset: 1 },
                                      { limit: 33, offset: 6 }]))
  end

  def test_user_page_size
    assert_equal(3, wf.user_page_size([offset: 3]))
    assert_equal(15, wf.user_page_size([nil, { offset: 15, limit: :lazy }]))
    assert_equal(25, wf.user_page_size([nil, { offset: 25 },
                                        { limit: :lazy }]))
    assert_equal(999, wf.user_page_size([a: 3, b: 2]))
  end

  def test_set_pagination
    assert_equal([nil, { offset: 5, limit: 10 }],
                 wf.set_pagination(5, 10, [nil, { offset: 0, limit: 100 }]))
    assert_equal([nil, { a: 1, b: 2 }],
                 wf.set_pagination(5, 10, [nil, { a: 1, b: 2 }]))
    assert_equal([nil, { offset: 15 }, { a: 2 }, { limit: 20 }],
                 wf.set_pagination(15, 20, [nil, { offset: 0 }, { a: 2 },
                                            { limit: 100 }]))
    assert_equal(['str1', { offset: 5, limit: 10 }, [1, 2]],
                 wf.set_pagination(5, 10, ['str1',
                                           { offset: 0, limit: 100 },
                                           [1, 2]]))
  end
end
