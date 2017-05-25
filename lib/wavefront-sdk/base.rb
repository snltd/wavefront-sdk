require 'json'
require 'time'
require 'faraday'
require 'pp'
require 'ostruct'
require_relative './exception'
require_relative './mixins'
require_relative './response'
require_relative './validators'
require_relative './version'

module Wavefront
  #
  # Abstract class from which all API classes inherit. When you make
  # any call to the Wavefront API from this SDK, you are returned an
  # OpenStruct object.
  #
  # @returns a Wavefront::Response object
  #
  class Base
    include Wavefront::Validators
    include Wavefront::Mixins
    attr_reader :opts, :debug, :noop, :verbose, :net, :api_base, :conn,
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
      @opts  = opts
      @debug = opts[:debug] || false
      @noop = opts[:noop] || false
      @verbose = opts[:verbose] || false
      @logger = opts[:logger] || nil
      setup_endpoint(creds)

      post_initialize(creds, opts) if respond_to?(:post_initialize)
    end

    # Convert an epoch timestamp into epoch milliseconds. If the
    # timestamp looks like it's already epoch milliseconds, return
    # it as-is.
    #
    # @param t [Integer] epoch timestamp
    # @return [Ingeter] epoch millisecond timestamp
    #
    def time_to_ms(t)
      return false unless t.is_a?(Integer)
      return t if t.to_s.size == 13
      (t.to_f * 1000).round
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
      Faraday.new(
        url:     "https://#{net[:endpoint]}" + [net[:api_base], path].uri_concat,
        headers: net[:headers].merge(headers)
      )
    end

    # Make a GET call to the Wavefront API and return the result as
    # a Ruby hash. Can optionally perform a verbose noop, if the
    # #noop class variable is set. If #verbose is set, then prints
    # the information used to build the URI.
    #
    # @param path [String] path to be appended to the
    #   #net[:api_base] path.
    # @param qs [String] optional query string
    # @return [Hash] API response
    #
    def api_get(path, query = {})
      make_call(mk_conn(path), :get, nil, query)
    end

    # Make a POST call to the Wavefront API and return the result as
    # a Ruby hash. Can optionally perform a verbose noop, if the
    # #noop class variable is set. If #verbose is set, then prints
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
      make_call(mk_conn(path, { 'Content-Type': ctype,
                                       'Accept': 'application/json'}),
                :post, nil, body)
    end

    # Make a PUT call to the Wavefront API and return the result as
    # a Ruby hash. Can optionally perform a verbose noop, if the
    # #noop class variable is set. If #verbose is set, then prints
    # the information used to build the URI.
    #
    # @param path [String] path to be appended to the
    #   #net[:api_base] path.
    # @param body [String] optional body text to post
    # @param ctype [String] the content type to use when putting
    # @return [Hash] API response
    #
    def api_put(path, body = nil, ctype = 'application/json')
      make_call(mk_conn(path, { 'Content-Type': ctype,
                                      'Accept': 'application/json' }),
                :put, nil, body.to_json)
    end

    # Make a DELETE call to the Wavefront API and return the result
    # as a Ruby hash. Can optionally perform a verbose noop, if the
    # #noop class variable is set. If #verbose is set, then prints
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
    # the keys returned by #describe().
    #
    # @param body [Hash] a hash of the existing object merged with the
    #   hash describing the user's change(s).
    # @param keys [Array, String] the keys(s) the user wishes to update
    # @return [Hash] a hash containing only the keys which need to be
    #   sent to the API. Keys will be symbolized.
    #
    def hash_for_update(old, new)
      raise ArgumentError unless old.is_a?(Hash) && new.is_a?(Hash)

      Hash[old.merge(new).map { |k, v| [k.to_sym, v] }].select do |k, _v|
        update_keys.include?(k)
      end
    end

    # Send a message to a Ruby logger object if the user supplied
    # one, or print to standard out if not.
    #
    # @param msg [String] the string to print
    # @param level [Symbol] the level of the message.
    #   :verbose messages equate to a standard INFO log level and
    #   :debug to DEBUG.
    #
    def log(msg, level = nil)

      if logger
        logger.send(level || :info, msg)
      else
        # print it unless it's a debug and we're not in debug
        #
        return if level == :debug && ! opts[:debug]
        return if level == :info && ! opts[:verbose]

        puts msg
      end
    end

    private

    # Try to describe the actual HTTP calls we make. There's a bit
    # of clumsy guesswork here
    #
    def verbosity(conn, method, *args)
      log "uri: #{method.upcase} #{conn.url_prefix}"

      if args.last && ! args.last.empty?
        puts log method == :get ? "params: #{args.last}" :
                                  "body: #{args.last}"
      end
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

      Wavefront::Response.new(resp.body || {}, debug)
    end

    def setup_endpoint(creds)
      %w(endpoint token).each do |k|
        raise "creds must contain #{k}" unless creds.key?(k.to_sym)
      end

      unless creds.key?(:agent) && creds[:agent]
        creds[:agent] = "wavefront-sdk #{WF_SDK_VERSION}"
      end

      @net = {
        headers:  { 'Authorization': "Bearer #{creds[:token]}",
                    'user-agent':    creds[:agent] },
        endpoint: creds[:endpoint],
        api_base: ['', 'api', 'v2', api_base].uri_concat
      }
    end
  end
end
