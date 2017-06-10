require 'json'
require_relative './exception'

module Wavefront

  class Response

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
    # @attr_reader debug [true, false] whether to print debugging
    #   information.
    #
    class Base
      attr_reader :status, :response #, :debug

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

        @status = build_status(raw, status)
        @response = build_response(raw)
      rescue => e
        puts e.message if debug
        raise Wavefront::Exception::InvalidResponse
      end

      def class_word
        self.class.name.split('::').last
      end

      def build_status(raw, status)
        begin
          Object.const_get("Wavefront::Type::Status#{class_word}").new(
            raw, status)
        rescue
          Object.const_get('Wavefront::Type::Status').new(raw, status)
        end
      end

      def build_response(raw)
        begin
          Object.const_get("Wavefront::Type::Response{class_word}").new(
            raw)
        rescue
          Object.const_get('Wavefront::Type::Response').new(raw)
        end
      end
    end
  end

  # These type classes encapsulate the Wavefront API responses. As
  # these responses are largely similar, but not the same, some
  # modules define their own types. When the response is
  # constructed, it will look for a type named
  # Wavefront::Type::StatusModule where Module is 'alert',
  # 'dashboard' etc. If that type is not defined, it falls back to
  # Wavefront::Type::Status and Wavefront::Type::Response as defined
  # here. The "module" types are defined in the same files as the API
  # classes which need them.
  #
  class Type
    #
    # An object which provides information about whether the request
    # was successful or not. Ordinarily this is easy to construct
    # from the API's JSON response, but sometimes it must be
    # manually built up, and other classes exist which do this.
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
    # is normally the hash of the response, with attr_readers for
    # each key.
    #
    class Response
      attr_reader :raw

      def initialize(raw)
        @raw = raw.key?(:response) ? raw[:response] : raw

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
