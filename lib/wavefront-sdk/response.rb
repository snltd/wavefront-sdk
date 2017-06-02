require 'json'
require_relative './exception'

module Wavefront

  # Every API path has its own response class, which allows us to
  # provide a stable interface. If the API changes underneath us,
  # the SDK will break in a predictable way, throwing a
  # Wavefront::Exception::InvalidResponse exception.
  #
  # Most Wavefront::Response classes present the returned data in
  # two parts, each accessible by dot notation.
  #   #status is the status object, which normally contains
  #   'result', 'message', and 'code'. It is a struct.
  #  #response contains the JSON response body, turned into a Ruby
  #  hash.
  #
  class Response
    class Base
      attr_reader :status, :response, :debug

      # Create and return a Wavefront::Response object
      # @param json [String] a raw response body from the Wavefront API
      # @param status [Integer] HTTP return code from the API
      # @param debug [Boolean] whether or not to print the exception
      #   message if one is thrown
      # @raise Wavefront::InvalidResponse if the response cannot be
      #   parsed
      # @return a Wavefront::Response object
      #
      def initialize(json, status, debug = false)
        @debug = debug
        populate(JSON.parse(json, symbolize_names: true), status)
      rescue => e
        puts e.message if debug
        raise Wavefront::Exception::InvalidResponse
      end

      def populate(raw, _status = 200)
        if raw.key?(:status)
          @status = Struct.new(*raw[:status].keys).
            new(*raw[:status].values).freeze
        end

        if raw.key?(:response)
          @response = Struct.new(*raw[:response].keys).
            new(*raw[:response].values).freeze
        end
      end
    end
  end
end
