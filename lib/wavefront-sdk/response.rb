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
      attr_reader :status, :response

      # Create and return a Wavefront::Response object
      # @param json [String] a raw response from the Wavefront API
      # @param debug [Boolean] whether or not to print the exception
      #   message if one is thrown
      # @raise Wavefront::InvalidResponse if the response cannot be
      #   parsed
      # @return a Wavefront::Response object
      #
      def initialize(json, debug = false)
        raw = JSON.parse(json, symbolize_names: true)
        @status = Struct.new(*raw[:status].keys).
                         new(*raw[:status].values).freeze
        @response = raw[:response].freeze
      rescue => e
        puts e.message if debug
        raise Wavefront::Exception::InvalidResponse
      end
    end
  end
end
