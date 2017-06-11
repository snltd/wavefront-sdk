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
  #
  # @!attribute [r] status
  #   @return [Wavefront::Types::Status]
  # @attr_reader response [Hash, Array] the JSON response body,
  #   turned into a Ruby object. All hash keys are symbols.
  #
  class Response
    attr_reader :status, :response, :debug

    # Create and return a Wavefront::Response object
    # @param json [String] a raw response body from the Wavefront API
    # @param status [Integer] HTTP return code from the API
    # @param debug [Boolean] whether or not to print the exception
    #   message if one is thrown
    # @raise [Wavefront::InvalidResponse] if the response cannot be
    #   parsed. This may be because the API itself has changed.
    #
    def initialize(json, status, debug = false)
      raw = json.empty? {} || JSON.parse(json, symbolize_names: true)

      @debug = debug
      @status = build_status(raw, status)
      @response = build_response(raw)
      p self if debug
    rescue => e
      p "could not parse:\n#{json}"
      p e
      puts e.message if debug
      raise Wavefront::Exception::InvalidResponse
    end

    def class_word
      self.class.name.split('::').last
    end

    def build_status(raw, status)
      Object.const_get('Wavefront::Type::Status').new(raw, status)
    rescue => e
      p e if debug
    end

    def build_response(raw)
      Object.const_get('Wavefront::Type::Response').new(raw)
    rescue => e
      p e if debug
    end
  end

  # These type classes encapsulate the Wavefront API responses.
  #
  class Type
    #
    # An object which provides information about whether the request
    # was successful or not. Ordinarily this is easy to construct
    # from the API's JSON response, but some classes, for instance
    # Wavefront::Write fake it by constructing their own.
    #
    # @!attribute [r] result
    #   @return [OK, ERROR] a string telling us how the request went
    # @!attribute [r] message
    #   @return [String] Any informational message from the API
    # @!attribute [r] code
    #   @return [Integer] the HTTP response code from the API
    #     request
    #
    class Status
      attr_reader :result, :message, :code

      # @param raw [Hash] the API response, turned into a hash
      # @param status [Integer] HTTP status code
      #
      def initialize(raw, status)
        obj = raw.key?(:status) ? raw[:status] : raw

        @result = obj[:result] || nil
        @message = obj[:message] || nil
        @code = obj[:code] || status
      end
    end

    # An object which contains the data returned from the API. This
    # is a hash of the response, with attr_readers for each key.
    #
    class Response
      attr_reader :raw

      def initialize(raw)
        @raw = raw.key?(:response) ? raw[:response] : raw

        # Most responses bundle multiple objects (like dashboards or
        # alerts) into an items array. Some (users) don't, so fake
        # the items for those.
        #
        @raw = { items: @raw } unless @raw.is_a?(Hash)

        @raw.each do |k, v|
          self.class.send(:attr_accessor, k)
          instance_variable_set("@#{k}", v)
        end
      end

      def [](k)
        raw[k.to_sym]
      end

      def keys
        raw.keys
      end
    end
  end
end
