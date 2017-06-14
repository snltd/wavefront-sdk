require 'json'
require 'map'
require_relative './exception'

module Wavefront

  # Every API path has its own response class, which allows us to
  # provide a stable interface. If the API changes underneath us,
  # the SDK will break in a predictable way, throwing a
  # Wavefront::Exception::UnparseableResponse exception.
  #
  # Most Wavefront::Response classes present the returned data in
  # two parts, each accessible by dot notation.
  #
  # @!attribute [r] status
  #   @return [Wavefront::Types::Status]
  # @!attribute [r] response
  #   @return [Map] the response from the API turned into a Map,
  #     which  allows
  #
  class Response
    attr_reader :status, :response

    # Create and return a Wavefront::Response object
    # @param json [String] a raw response body from the Wavefront API
    # @param status [Integer] HTTP return code from the API
    # @param debug [Boolean] whether or not to print the exception
    #   message if one is thrown
    # @raise [Wavefront::Exception::UnparseableResponse] if the
    #   response cannot be parsed. This may be because the API
    #   has changed underneath us.
    #
    def initialize(json, status, debug = false)
      begin
        raw = json.empty? ? {} : JSON.parse(json, symbolize_names: true)
      rescue
        raw = { message: json, code: status }
      end

      @status = build_status(raw, status)
      @response = build_response(raw)
      p self if debug
    rescue => e
      puts "could not parse:\n#{json}" if debug
      puts e.message if debug
      raise Wavefront::Exception::UnparseableResponse
    end

    def build_status(raw, status)
      Wavefront::Type::Status.new(raw, status)
    end

    def build_response(raw)
      if raw.is_a?(Hash)
        if raw.key?(:response)
          Map(raw[:response])
        else
          Map.new
        end
      else
        Map.new
      end
    end
  end

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

        @message = obj[:message] || nil
        @code = obj[:code] || status

        @result = if obj[:result]
                    obj[:result]
                  elsif status == 200
                    'OK'
                  else
                    'ERROR'
                  end
      end
    end
  end
end
