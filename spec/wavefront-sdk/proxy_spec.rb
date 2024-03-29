#!/usr/bin/env ruby
# frozen_string_literal: true

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

  def test_shutdown
    assert_puts("/api/v2/proxy/#{id}", { shutdown: true }.to_json, :json) do
      wf.shutdown(id)
    end
  end

  def test_config
    assert_invalid_id { wf.config(invalid_id) }

    assert_gets("/api/v2/proxy/#{id}/config") { wf.config(id) }
  end

  def test_preprocessor_rules
    assert_invalid_id { wf.preprocessor_rules(invalid_id) }

    assert_gets("/api/v2/proxy/#{id}/preprocessorRules") do
      wf.preprocessor_rules(id)
    end
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
