#!/usr/bin/env ruby

require_relative '../../spec_helper'
require_relative '../../../lib/wavefront-sdk/core/api'

# Test SDK core API class
#
class WavefrontCoreApiTest < MiniTest::Test
  attr_reader :wf

  def setup
    @wf = Wavefront::CoreApi.new(CREDS)
  end

  def test_time_to_ms
    now_ms = Time.now.to_i * 1000
    assert_equal(now_ms, wf.time_to_ms(now_ms))
    assert_equal(1_469_711_187_000, wf.time_to_ms(1_469_711_187))
    refute wf.time_to_ms([])
    refute wf.time_to_ms('1469711187')
  end

  def test_hash_for_update
    wf.instance_variable_set('@update_keys', %i[k1 k2])
    body = { k1: 'ov1', k2: 'ov2', k3: 'ov3' }
    upd = { k2: 'nv1' }
    assert_equal({ k1: 'ov1', k2: 'nv1' }, wf.hash_for_update(body, upd))
  end
end
