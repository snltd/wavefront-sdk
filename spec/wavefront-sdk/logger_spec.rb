#!/usr/bin/env ruby

require 'logger'
require_relative '../spec_helper'
require_relative '../../lib/wavefront-sdk/logger'

# Test SDK logger class
#
class WavefrontBaseTest < MiniTest::Test
  attr_reader :wfl

  def setup
    @wfl = Wavefront::Logger.new
  end

  def test_format_message
    assert_equal('SDK INFO: some text', wfl.format_message(:info,
                                                           'some text'))
  end

  def test_log_no_logger_debug
    l = Wavefront::Logger.new(debug: true)
    assert_output("SDK DEBUG: my message\n") { l.log('my message', :debug) }
    assert_output("SDK INFO: my message\n") { l.log('my message', :info) }
    out, err = capture_io { l.log('my message', :error) }
    assert_equal("SDK ERROR: my message\n", err)
    assert_empty(out)
  end

  def test_log_no_logger_no_debug
    l = Wavefront::Logger.new({debug: false, verbose: false})
    assert_silent { l.log('my message', :debug) }
    assert_output("SDK INFO: my message\n") { l.log('my message', :info) }
    out, err = capture_io { l.log('my message', :error) }
    assert_equal("SDK ERROR: my message\n", err)
    assert_empty(out)
    out, err = capture_io { l.log('my message', :warn) }
    assert_equal("SDK WARN: my message\n", err)
    assert_empty(out)
  end

  def test_log_logger_debug
    l = Wavefront::Logger.new(logger: Logger.new(STDOUT))
    out, err = capture_subprocess_io { l.log('my message', :debug) }
    assert_match(/DEBUG -- : my message$/, out)
  end

  def test_log_logger_info
    l = Wavefront::Logger.new(logger: Logger.new(STDOUT))
    out, err = capture_subprocess_io { l.log('my message', :info) }
    assert_match(/INFO -- : my message$/, out)
  end

  def test_log_logger_error
    l = Wavefront::Logger.new(logger: Logger.new(STDOUT))
    out, err = capture_subprocess_io { l.log('my message', :error) }
    assert_match(/ERROR -- : my message$/, out)
  end
end
