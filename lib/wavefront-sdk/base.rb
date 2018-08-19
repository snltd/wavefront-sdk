require 'json'
require 'time'
require 'faraday'
require 'pp'
require 'ostruct'
require 'addressable'
require_relative 'logger'
require_relative 'exception'
require_relative 'mixins'
require_relative 'response'
require_relative 'validators'
require_relative 'version'

module Wavefront
  #
  # Abstract class from which all API classes inherit. When you make
  # any call to the Wavefront API from this SDK, you are returned an
  # OpenStruct object.
  #
  # @return a Wavefront::Response object
  #
  class Base
    include Wavefront::Validators
    include Wavefront::Mixins
    attr_reader :opts, :debug, :noop, :verbose, :net, :conn,
                :update_keys, :logger

    # Create a new API object. This will always be called from a
    # class which inherits this one. If the inheriting class defines
    # #post_initialize, that method will be called afterwards, with
    # the same arguments.
    #
    # @param creds [Hash] must contain the keys `endpoint` (the
    #   Wavefront API server) and `token`, the user token with which
    #   you wish to access the endpoint. Can optionally contain
    #   `agent`, which will become the `user-agent` string sent with
    #   all requests.
    # @param opts [Hash] options governing class behaviour. Expected
    #   keys are `debug`, `noop` and `verbose`, all boolean; and
    #   `logger`, which must be a standard Ruby logger object. You
    #   can also pass :response_only. If this is true, you will only
    #   be returned a hash of the 'response' object returned by
    #   Wavefront.
    # @return [Nil]
    #
    def initialize(creds = {}, opts = {})
      @opts    = opts
      @debug   = opts[:debug] || false
      @noop    = opts[:noop] || false
      @verbose = opts[:verbose] || false
      @logger  = Wavefront::Logger.new(opts)
      setup_endpoint(creds)
      post_initialize(creds, opts) if respond_to?(:post_initialize)
    end

    def log(message, severity = :info)
      logger.log(message, severity)
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

    # Derive the first part of the API path from the class name. You
    # can override this in your class if you wish
    #
    # @return [String] portion of API URI
    #
    def api_base
      self.class.name.split('::').last.downcase
    end

    # Create a Faraday connection object. The server comes from the
    # endpoint passed to the initializer in the 'creds' hash; the
    # root of the URI is dynamically derived by the #setup_endpoint
    # method.
    #
    # @param headers [Hash] additional headers
    # @return [URI::HTTPS]
    #
    def mk_conn(path, headers = {})
      url = format('https://%s%s', net[:endpoint], [net[:api_base],
                                                    path].uri_concat)
      Faraday.new(url:     Addressable::URI.encode(url),
                  headers: net[:headers].merge(headers))
    end

    # Make a GET call to the Wavefront API and return the result as
    # a Ruby hash. Can optionally perform a verbose noop, if the
    # @noop class variable is set. If @verbose is set, then prints
    # the information used to build the URI.
    #
    # @param path [String] path to be appended to the
    #   #net[:api_base] path.
    # @param query [Hash] optional key-value pairs with will be made
    #   into aquery string
    # @return [Hash] API response
    #
    def api_get(path, query = {})
      make_call(mk_conn(path), :get, nil, query)
    end

    # Make a POST call to the Wavefront API and return the result as
    # a Ruby hash. Can optionally perform a verbose noop, if the
    # @noop class variable is set. If @verbose is set, then prints
    # the information used to build the URI.
    #
    # @param path [String] path to be appended to the
    #   #net[:api_base] path.
    # @param body [String] optional body text to post
    # @param ctype [String] the content type to use when posting
    # @return [Hash] API response
    #
    def api_post(path, body = nil, ctype = 'text/plain')
      body = body.to_json unless body.is_a?(String)
      make_call(mk_conn(path,  'Content-Type': ctype,
                               'Accept': 'application/json'),
                :post, nil, body)
    end

    # Make a PUT call to the Wavefront API and return the result as
    # a Ruby hash. Can optionally perform a verbose noop, if the
    # @noop class variable is set. If @verbose is set, then prints
    # the information used to build the URI.
    #
    # @param path [String] path to be appended to the
    #   #net[:api_base] path.
    # @param body [String] optional body text to post
    # @param ctype [String] the content type to use when putting
    # @return [Hash] API response
    #
    def api_put(path, body = nil, ctype = 'application/json')
      make_call(mk_conn(path,  'Content-Type': ctype,
                               'Accept': 'application/json'),
                :put, nil, body.to_json)
    end

    # Make a DELETE call to the Wavefront API and return the result
    # as a Ruby hash. Can optionally perform a verbose noop, if the
    # @noop class variable is set. If @verbose is set, then prints
    # the information used to build the URI.
    #
    # @param path [String] path to be appended to the
    #   #net[:api_base] path.
    # @return [Hash] API response
    #
    def api_delete(path)
      make_call(mk_conn(path), :delete)
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

    # If we need to massage a raw response to fit what the
    # Wavefront::Response class expects (I'm looking at you,
    # 'User'), a class can provide a {#response_shim} method.
    #
    def respond(resp)
      body = if respond_to?(:response_shim)
               response_shim(resp.body, resp.status)
             else
               resp.body
             end

      Wavefront::Response.new(body, resp.status, opts)
    end

    # Return all objects using a lazy enumerator
    # @return Enumerable
    #
    def everything
      Enumerator.new do |y|
        offset = 0
        limit = 100

        loop do
          resp = api_get('', offset: offset, limit: limit).response
          resp.items.map { |i| y.<< i }
          offset += limit
          raise StopIteration unless resp.moreItems == true
        end
      end.lazy
    end

    def api_path
      ['', 'api', 'v2', api_base].uri_concat
    end

    private

    # Try to describe the actual HTTP calls we make. There's a bit
    # of clumsy guesswork here
    #
    def verbosity(conn, method, *args)
      log format('uri: %s %s', method.upcase, conn.url_prefix)

      return unless args.last && !args.last.empty?

      log method == :get ? "params: #{args.last}" : "body: #{args.last}"
    end

    # Make the API call, or not, if noop is set.
    #
    def make_call(conn, method, *args)
      verbosity(conn, method, *args) if noop || verbose
      return if noop

      resp = conn.public_send(method, *args)

      if debug
        require 'pp'
        pp resp
      end

      respond(resp)
    end

    def validate_credentials(creds)
      %w[endpoint token].each do |k|
        unless creds.key?(k.to_sym)
          raise(Wavefront::Exception::CredentialError,
                format('credentials must contain %s', k))
        end
      end
    end

    def setup_endpoint(creds)
      validate_credentials(creds)

      unless creds.key?(:agent) && creds[:agent]
        creds[:agent] = "wavefront-sdk #{WF_SDK_VERSION}"
      end

      @net = { headers:  { 'Authorization': "Bearer #{creds[:token]}",
                           'user-agent':    creds[:agent] },
               endpoint: creds[:endpoint],
               api_base: api_path }
    end
  end
end
