#!/usr/bin/env ruby

require_relative './spec_helper'

# Unit tests for MaintenanceWindow class
#
class WavefrontMaintenanceWindowTest < WavefrontTestBase

  def test_list
    should_work('list', 10, '?offset=10&limit=100')
  end

  def test_describe
    should_work('describe', MAINTENANCE_WINDOW, MAINTENANCE_WINDOW)
    should_be_invalid('describe', 'abcdefg')
    assert_raises(ArgumentError) { wf.describe }
  end

  def test_create
    should_work('create', '', MAINTENANCE_WINDOW_BODY, :post)
    assert_raises(ArgumentError) { wf.create }

    b = MAINTENANCE_WINDOW_BODY
    b.delete(:name)
    assert_raises(ArgumentError) { wf.create(b) }

    b = MAINTENANCE_WINDOW_BODY
    b[:template] = 'some_nonsense'
    assert_raises(Wavefront::Exception::InvalidURI) { wf.create(b) }
  end

  def test_delete
    should_work('delete', MAINTENANCE_WINDOW, MAINTENANCE_WINDOW, :delete)
    should_be_invalid('delete', 'abcdefg')
    assert_raises(ArgumentError) { wf.delete }
  end

  def test_update
    should_work('update', MAINTENANCE_WINDOW,
                [MAINTENANCE_WINDOW, MAINTENANCE_WINDOW_BODY], :post)
    assert_raises(ArgumentError) { wf.update }
    assert_raises(ArgumentError) { wf.update(MAINTENANCE_WINDOW) }

    b = MAINTENANCE_WINDOW_BODY
    b.delete(:name)
    assert_raises(ArgumentError) { wf.create(MAINTENANCE_WINDOW, b) }

    b = MAINTENANCE_WINDOW_BODY
    b[:template] = 'some_nonsense'
    assert_raises(Wavefront::Exception::InvalidURI) {
      wf.create(MAINTENANCE_WINDOW, b)
    }
  end
end
