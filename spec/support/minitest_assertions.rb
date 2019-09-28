# frozen_string_literal: true

module Minitest
  #
  # Some custom Minitest assertions to simplify testing
  #
  module Assertions
    # Ensure the given call raises the correct InvalidId exception
    # @param block [Proc] call to Wavefront SDK method
    #
    def assert_invalid_id(&block)
      assert_raises(standard_exception) { yield block }
    end

    # Ensure that the correct API path is called by the given call
    # @param api_path [String] full API path to be called
    # @param block [Proc] call to SDK method
    #
    def assert_gets(api_path, &block)
      headers = DEFAULT_HEADERS
      stub_request(:get, uri(api_path))
        .with(headers: headers)
        .to_return(body: DUMMY_RESPONSE, status: 200)
      yield block
      assert_requested(:get, uri(api_path), headers: headers)
      WebMock.reset!
    end

    # Ensure that the correct API path is hit by the given call, and
    # that the correct HTTP payload is sent
    # @param api_path [String] full API path to be called
    # @param payload [Object] Ruby representation of payload we expect
    #   to see
    # @param type [Symbol] override the content type
    # @param block [Proc] call to SDK method
    #
    def assert_posts(api_path, payload = nil, type = nil, &block)
      headers = DEFAULT_HEADERS.merge(extra_headers(payload, type))
      payload = 'null' if payload.nil?
      stub_request(:post, uri(api_path))
        .with(body: payload, headers: headers)
        .to_return(body: DUMMY_RESPONSE, status: 200)
      yield block
      assert_requested(:post, uri(api_path), headers: headers)
      WebMock.reset!
    end

    # Ensure that the correct API path is hit by the given call, and
    # that the correct HTTP payload is sent
    # @param api_path [String] full API path to be called
    # @param payload [Object] Ruby representation of payload we expect
    #   to see
    # @param type [Symbol] override the content type
    # @param block [Proc] call to SDK method
    #
    def assert_puts(api_path, payload = nil, type = nil, &block)
      headers = DEFAULT_HEADERS.merge(extra_headers(payload, type))
      payload = 'null' if payload.nil?
      stub_request(:put, uri(api_path))
        .with(body: payload, headers: headers)
        .to_return(body: DUMMY_RESPONSE, status: 200)
      yield block
      assert_requested(:put, uri(api_path), headers: headers)
      WebMock.reset!
    end

    # Ensure that the correct API path is called by the given call
    # @param api_path [String] full API path to be called
    # @param block [Proc] call to SDK method
    #
    def assert_deletes(api_path, &block)
      headers = DEFAULT_HEADERS
      stub_request(:delete, uri(api_path))
        .with(headers: headers)
        .to_return(body: DUMMY_RESPONSE, status: 200)
      yield block
      assert_requested(:delete, uri(api_path), headers: headers)
      WebMock.reset!
    end

    private

    def uri(api_path)
      "https://#{CREDS[:endpoint]}#{api_path}"
    end

    def extra_headers(payload, type)
      if type
        header_lookup(type)
      elsif payload.nil?
        header_lookup(:plain)
      elsif type.nil?
        header_lookup(:json)
      end
    end

    def header_lookup(type)
      ctype = case type
              when :plain
                'text/plain'
              when :json
                'application/json'
              when :octet
                'application/octet-stream'
              when :form
                'application/x-www-form-urlencoded'
              end

      { 'Content-Type': ctype, Accept: 'application/json' }
    end
  end
end
