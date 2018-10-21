#!/usr/bin/env ruby

require_relative '../../spec_helper'
require_relative '../resources/dummy_points'
require_relative '../../../lib/wavefront-sdk/write'

HEADERS = POST_HEADERS.merge('Content-Type': 'application/octet-stream')

# The report class test will test that an API call is made. Here all
# that's left to test is the #validate_credentials method.
#
class WavefrontWriterApiTest < MiniTest::Test
  attr_reader :wf

  def setup
    @wf = Wavefront::Write.new(CREDS, writer: :api)
  end

  def test_writer_class
    assert_instance_of(Wavefront::Writer::Api, wf.writer)
  end

  def test_validate_credentials
    assert(Wavefront::Write.new(CREDS, writer: :api))

    assert_instance_of(Wavefront::Write,
                       Wavefront::Write.new(CREDS, writer: :api))

    assert_raises(Wavefront::Exception::CredentialError) do
      Wavefront::Write.new({}, writer: :api)
    end

    assert_raises(Wavefront::Exception::CredentialError) do
      Wavefront::Write.new({ proxy: 'wavefront' }, writer: :api)
    end

    assert_raises(Wavefront::Exception::CredentialError) do
      Wavefront::Write.new({ endpoint: 'wavefront.com' }, writer: :api)
    end

    assert_raises(Wavefront::Exception::CredentialError) do
      Wavefront::Write.new({ token: 'abcdef' }, writer: :api)
    end
  end
end
