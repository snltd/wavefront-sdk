require 'simplecov'
SimpleCov.start { add_filter '/spec/' }
require 'minitest/autorun'
require 'spy/integration'
require 'webmock/minitest'
require_relative 'support/minitest_assertions'
require_relative 'constants'

# Abstract class which sets up everything needed by the API tests
#
class WavefrontTestBase < MiniTest::Test
  attr_reader :wf, :wf_noop, :headers, :invalid_id, :valid_id

  def initialize(args)
    require_relative "../lib/wavefront-sdk/#{class_basename.downcase}"
    setup_fixtures if respond_to?(:setup_fixtures)
    super(args)
  end

  private

  def setup
    @wf = Object.const_get("Wavefront::#{class_basename}").new(CREDS)
  end

  def class_basename
    self.class.name.match(/Wavefront(\w+)Test/)[1]
  end

  def standard_exception
    Object.const_get("Wavefront::Exception::Invalid#{class_basename}Id")
  end
end
