require 'json'
require 'map'
require_relative 'mixins'
require_relative 'logger'
require_relative 'exception'
require_relative 'types/status'

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
      setup_vars(opts)
      raw       = raw_response(json, status)
      @status   = build_status(raw, status)
      @response = build_response(raw)
      logger.log(self, :debug)
    rescue StandardError => e
      logger.log(format("could not parse:\n%s", json), :debug)
      logger.log(e.message.to_s, :debug)
      raise Wavefront::Exception::UnparseableResponse
    end

    # Was the API's response positive?
    # @return [Bool]
    #
    def ok?
      respond_to?(:status) && status.result == 'OK'
    end

    # Are there more items in paginated output?
    # @return [Bool]
    #
    def more_items?
      return false unless response.key?(:moreItems)
      !!response.moreItems
    end

    # On paginated output, the offset of the next item, or nil.
    # @return [Integer, Nil]
    #
    def next_item
      return nil unless more_items?
      reponse.offset + response.limit
    rescue StandardError
      nil
    end

    # A printable version of a Wavefront::Response object
    # @return [String]
    #
    def to_s
      inspect.to_s
    end

    private

    def setup_vars(opts)
      @opts   = opts
      @logger = Wavefront::Logger.new(opts)
    end

    # @params raw [Hash] created by #raw_response
    #
    def build_response(raw)
      return Map.new unless raw.is_a?(Hash)
      return Map.new(raw) unless raw.key?(:response)
      return raw[:response] unless raw[:response].is_a?(Hash)
      Map(raw[:response])
    end

    # Turn the API's JSON response and HTTP status code into a Ruby
    # object.
    # @return [Hash]
    #
    def raw_response(json, status)
      json.empty? ? {} : JSON.parse(json, symbolize_names: true)
    rescue StandardError
      { message: json, code: status }
    end

    def build_status(raw, status)
      Wavefront::Type::Status.new(raw, status)
    end
  end
end
