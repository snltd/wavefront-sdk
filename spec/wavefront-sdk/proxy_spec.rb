#!/usr/bin/env ruby

require_relative './spec_helper'

PROXY = 'fd248f53-378e-4fbe-bbd3-efabace8d724'.freeze

# Unit tests for proxy class
#
class WavefrontProxyTest < WavefrontTestBase
  def test_list
    should_work(:list, 10, '?offset=10&limit=100')
  end

  def test_describe
    should_work(:describe, PROXY, PROXY)
    should_be_invalid(:describe)
    assert_raises(ArgumentError) { wf.describe }
  end

  def test_delete
    should_work(:delete, PROXY, PROXY, :delete)
    should_be_invalid('delete')
  end

  def test_rename
    should_work(:rename, [PROXY, 'newname'],
                [PROXY, { name: 'newname' }.to_json], :put,
                JSON_POST_HEADERS)
    assert_raises(ArgumentError) { wf.rename }
    assert_raises(ArgumentError) { wf.rename('abc123') }
    assert_raises(Wavefront::Exception::InvalidProxyId) do
      wf.rename('abc', 'name')
    end
  end

  def test_undelete
    should_work(:undelete, PROXY, ["#{PROXY}/undelete", nil],
                :post, POST_HEADERS)
    should_be_invalid('undelete')
  end
end
