# frozen_string_literal: true

require_relative 'logger'
require_relative 'api_caller'
require_relative 'exception'
require_relative '../validators'
require_relative '../support/mixins'

module Wavefront
  #
  # Abstract class from which all API classes inherit. When you make
  # any call to the Wavefront API from this SDK, you are returned an
  # OpenStruct object.
  #
  # @return a Wavefront::Response object
  #
  class CoreApi
    include Wavefront::Validators
    include Wavefront::Mixins
    attr_reader :api, :update_keys, :logger, :creds, :opts

    # Create a new API object. This will always be called from a
    # class which inherits this one. If the inheriting class defines
    # #post_initialize, that method will be called afterwards, with
    # the same arguments.
    #
    # @param creds [Hash] must contain the keys `endpoint` (the
    #   Wavefront API server) and `token`, the user token with which
    #   you wish to access the endpoint. Can optionally contain
    #   `agent`, which will become the `user-agent` string sent with
    #   all requests. Passed through to the ApiCaller class.
    # @param opts [Hash] options governing class behaviour. Expected
    #   keys are `debug`, `noop` and `verbose`, all boolean; and
    #   `logger`, which must be a standard Ruby logger object. You
    #   can also pass :response_only. If this is true, you will only
    #   be returned a hash of the 'response' object returned by
    #   Wavefront. Passed through to the ApiCaller class.
    # @return [Nil]
    #
    def initialize(creds = {}, opts = {})
      @creds   = creds
      @opts    = opts
      @api     = setup_api(creds, opts)
      @s_api   = setup_api(creds, opts)
      @logger  = Wavefront::Logger.new(opts)
      post_initialize(creds, opts) if respond_to?(:post_initialize)
    end

    def setup_api(creds, opts)
      Wavefront::ApiCaller.new(self, creds, opts)
    end

    # Derive the first part of the API path from the class name. You
    # can override this in your class if you wish. This method is
    # called by the ApiCaller class.
    #
    # @return [String] portion of API URI
    #
    def api_base
      self.class.name.split('::').last.downcase
    end

    # The API path is normally /api/v2/something, but not always.
    # Override this method if not
    #
    def api_path
      ['', 'api', 'v2', api_base].uri_concat
    end

    # Convert an epoch timestamp into epoch milliseconds. If the
    # timestamp looks like it's already epoch milliseconds, return
    # it as-is.
    #
    # @param t [Integer] epoch timestamp
    # @return [Ingeter] epoch millisecond timestamp
    #
    def time_to_ms(time)
      return false unless time.is_a?(Integer)
      return time if time.to_s.size == 13

      (time.to_f * 1000).round
    end

    # doing a PUT to update an object requires only a certain subset of
    # the keys returned by #describe(). This method takes the
    # existing description of an object and turns it into a new has
    # which can be PUT.
    #
    # @param old [Hash] a hash of the existing object
    # @param new [Hash] the keys you wish to update
    # @return [Hash] a hash containing only the keys which need to be
    #   sent to the API. Keys will be symbolized.
    #
    def hash_for_update(old, new)
      raise ArgumentError unless old.is_a?(Hash) && new.is_a?(Hash)

      Hash[old.merge(new).map { |k, v| [k.to_sym, v] }].select do |k, _v|
        update_keys.include?(k)
      end
    end
  end
end
