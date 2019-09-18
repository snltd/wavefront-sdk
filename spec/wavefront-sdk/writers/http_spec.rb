#!/usr/bin/env ruby
# frozen_string_literal: true

require_relative '../../spec_helper'
require_relative '../resources/dummy_points'
require_relative '../../../lib/wavefront-sdk/write'

BODY = 'test.metric 123456 1469987572 source=testhost t1="v1" t2="v2"'

# Test HTTP transport
#
class WavefrontWriterSocketTest < MiniTest::Test
  attr_reader :wf

  def setup
    @wf = Wavefront::Write.new({ proxy: 'wavefront' }, writer: :http)
  end

  def test_writer_class
    assert_instance_of(Wavefront::Writer::Http, wf.writer)
  end

  def test_validate_credentials
    assert Wavefront::Write.new({ proxy: 'wavefront' }, writer: :http)
    assert_instance_of(Wavefront::Write, wf)

    assert_raises(Wavefront::Exception::CredentialError) do
      Wavefront::Write.new(CREDS, writer: :http)
    end

    assert_raises(Wavefront::Exception::CredentialError) do
      Wavefront::Write.new({}, writer: :http)
    end

    assert_raises(Wavefront::Exception::CredentialError) do
      Wavefront::Write.new({ endpoint: 'wavefront.com' }, writer: :http)
    end

    assert_raises(Wavefront::Exception::CredentialError) do
      Wavefront::Write.new({ token: 'abcdef' }, writer: :http)
    end
  end

  def test_write_2878
    wf1 = Wavefront::Write.new({ proxy: 'wavefront' }, writer: :http)

    stub_request(:post, 'http://wavefront:2878')
      .with(body: BODY, headers: POST_HEADERS)
      .to_return(body: DUMMY_RESPONSE, status: 200)

    wf1.write(POINT)

    assert_requested(:post, 'http://wavefront:2878', headers: POST_HEADERS)
    WebMock.reset!
  end

  def test_write_1234
    wf1 = Wavefront::Write.new({ proxy: 'wavefront', port: 1234 },
                               writer: :http)

    stub_request(:post, 'http://wavefront:1234')
      .with(body: BODY, headers: POST_HEADERS)
      .to_return(body: DUMMY_RESPONSE, status: 200)

    wf1.write(POINT)

    assert_requested(:post, 'http://wavefront:1234', headers: POST_HEADERS)
    WebMock.reset!
  end
end
