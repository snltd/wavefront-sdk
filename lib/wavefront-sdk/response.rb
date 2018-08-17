require 'json'
require 'map'
require_relative 'exception'
require_relative 'mixins'

module Wavefront
  #
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
    include Wavefront::Mixins
    attr_reader :status, :response, :opts, :logger

    # Create and return a Wavefront::Response object
    # @param json [String] a raw response body from the Wavefront API
    # @param status [Integer] HTTP return code from the API
    # @param opts [Hash] options passed through from calling class.
    # @raise [Wavefront::Exception::UnparseableResponse] if the
    #   response cannot be parsed. This may be because the API
    #   has changed underneath us.
    #
    def initialize(json, status, opts = {})
      raw       = raw_response(json, status)
      @status   = build_status(raw, status)
      @response = build_response(raw)
      @opts     = opts

      setup_opts

      logger.log(self, :debug)
    rescue StandardError => e
      logger.log(format("could not parse:\n%s", json), :debug)
      logger.log(e.message.to_s, :debug)
      raise Wavefront::Exception::UnparseableResponse
    end

    def setup_opts
      @logger = Wavefront::Logger.new(opts)
    end

    def raw_response(json, status)
      json.empty? ? {} : JSON.parse(json, symbolize_names: true)
    rescue StandardError
      { message: json, code: status }
    end

    def build_status(raw, status)
      Wavefront::Type::Status.new(raw, status)
    end

    def build_response(raw)
      return Map.new unless raw.is_a?(Hash)
      return Map.new(raw) unless raw.key?(:response)
      return raw[:response] unless raw[:response].is_a?(Hash)
      Map(raw[:response])
    end
  end

  # Status types are used by the Wavefront::Response class
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
      attr_reader :obj, :status

      # @param response [Hash] the API response, turned into a hash
      # @param status [Integer] HTTP status code
      #
      def initialize(response, status)
        @obj = response.fetch(:status, response)
        @status = status
      end

      def message
        obj[:message] || nil
      end

      def code
        obj[:code] || status
      end

      def result
        return obj[:result] if obj[:result]
        return 'OK' if status.between?(200, 299)
        'ERROR'
      end
    end
  end
end
