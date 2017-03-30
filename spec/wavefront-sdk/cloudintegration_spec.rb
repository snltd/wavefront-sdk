#!/usr/bin/env ruby

require_relative './spec_helper'

# Unit tests for CloudIntegration class
#
class WavefrontCloudIntegrationTest < WavefrontTestBase
  def test_list
    should_work('list', 10, '?offset=10&limit=100')
  end

  def test_create
  end

  def test_delete
    should_work('delete', CLOUD, CLOUD, :delete)
    should_be_invalid('delete')
  end

  def test_describe
    should_work('describe', CLOUD, CLOUD)
    should_be_invalid('describe')
  end

  def test_update
  end

  def test_undelete
    should_work('undelete', CLOUD, ["#{CLOUD}/undelete", nil], :post,
                POST_HEADERS)
    should_be_invalid('undelete')
  end
end
