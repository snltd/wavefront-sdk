#!/usr/bin/env ruby

require_relative '../spec_helper'
require_relative '../test_mixins/general'

# Unit tests for proxy class
#
class WavefrontProxyTest < WavefrontTestBase
  include WavefrontTest::DeleteUndelete
  include WavefrontTest::Describe
  include WavefrontTest::List

  def test_rename
    assert_puts("/api/v2/proxy/#{id}", name: 'newname') do
      wf.rename(id, 'newname')
    end

    assert_invalid_id { wf.rename(invalid_id, 'newname') }
    assert_raises(ArgumentError) { wf.rename(id) }
    assert_raises(ArgumentError) { wf.rename }
  end

  private

  def api_class
    'proxy'
  end

  def id
    'fd248f53-378e-4fbe-bbd3-efabace8d724'
  end

  def invalid_id
    'my awesome stupid proxy id'
  end
end
