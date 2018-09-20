require 'json'
require 'faraday'
require 'addressable'
require_relative 'response'
require_relative '../defs/version'
require_relative '../support/mixins'

module Wavefront
  #
  # Constructs and makes API calls to Wavefront.
  #
  class ApiCaller
    include Wavefront::Mixins

    attr_reader :noop, :debug, :verbose, :net, :logger, :calling_class

    # @param calling_class [
    # @param creds [Hash] Wavefront credentials
    # @param opts [Hash]
    # @return [Nil]
    #
    def initialize(calling_class, creds = {}, opts = {})
      @calling_class = calling_class
      @opts          = opts
      setup_class_vars(opts)
      setup_endpoint(creds)
    end

    def setup_class_vars(opts)
      @logger    = Wavefront::Logger.new(opts)
      @noop      = opts[:noop] || false
      @verbose   = opts[:verbose] || false
      @debug     = opts[:debug] || false
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
    # a Ruby hash.
    #
    # @param path [String] path to be appended to the
    #   #net[:api_base] path.
    # @param query [Hash] optional key-value pairs with will be made
    #   into aquery string
    # @return [Hash] API response
    #
    def get(path, query = {})
      make_call(mk_conn(path), :get, nil, query)
    end

    # Make a POST call to the Wavefront API and return the result as
    # a Ruby hash.
    #
    # @param path [String] path to be appended to the
    #   #net[:api_base] path.
    # @param body [String,Object] optional body text to post.
    #   Objects will be converted to JSON
    # @param ctype [String] the content type to use when posting
    # @return [Hash] API response
    #
    def post(path, body = nil, ctype = 'text/plain')
      body = body.to_json unless body.is_a?(String)
      make_call(mk_conn(path,  'Content-Type': ctype,
                               'Accept': 'application/json'),
                :post, nil, body)
    end

    # Make a PUT call to the Wavefront API and return the result as
    # a Ruby hash.
    #
    # @param path [String] path to be appended to the
    #   #net[:api_base] path.
    # @param body [String] optional body text to post
    # @param ctype [String] the content type to use when putting
    # @return [Hash] API response
    #
    def put(path, body = nil, ctype = 'application/json')
      make_call(mk_conn(path,  'Content-Type': ctype,
                               'Accept': 'application/json'),
                :put, nil, body.to_json)
    end

    # Make a DELETE call to the Wavefront API and return the result
    # as a Ruby hash.
    #
    # @param path [String] path to be appended to the
    #   #net[:api_base] path.
    # @return [Hash] API response
    #
    def delete(path)
      make_call(mk_conn(path), :delete)
    end

    # If we need to massage a raw response to fit what the
    # Wavefront::Response class expects (I'm looking at you,
    # 'User'), a class can provide a {#response_shim} method.
    #
    def respond(resp)
      body = if calling_class.respond_to?(:response_shim)
               calling_class.response_shim(resp.body, resp.status)
             else
               resp.body
             end

      Wavefront::Response.new(body, resp.status, @opts)
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

    def paginator_class(method)
      require_relative File.join('..', 'paginator', method.to_s)
      Object.const_get(format('Wavefront::Paginator::%s',
                              method.to_s.capitalize))
    end

    # A dispatcher for making API calls. We now have three methods
    # that do the real call, two of which live inside the requisite
    # Wavefront::Paginator class
    #
    def make_call(conn, method, *args)
      verbosity(conn, method, *args) if noop || verbose
      return if noop

      paginator = paginator_class(method).new(self, conn, method, *args)

      case paginator.limit_and_offset(args)[:limit]
      when :all, 'all'
        paginator.make_recursive_call
      when :lazy, 'lazy'
        paginator.make_lazy_call
      else
        make_single_call(conn, method, *args)
      end
    end

    def make_single_call(conn, method, *args)
      resp = conn.public_send(method, *args)

      if debug
        require 'pp'
        pp resp
      end

      respond(resp)
    end

    def setup_endpoint(creds)
      validate_credentials(creds)

      unless creds.key?(:agent) && creds[:agent]
        creds[:agent] = "wavefront-sdk #{WF_SDK_VERSION}"
      end

      @net = { headers:  { 'Authorization': "Bearer #{creds[:token]}",
                           'user-agent':    creds[:agent] },
               endpoint: creds[:endpoint],
               api_base: calling_class.api_path }
    end

    def validate_credentials(creds)
      %w[endpoint token].each do |k|
        unless creds.key?(k.to_sym)
          raise(Wavefront::Exception::CredentialError,
                format('credentials must contain %s', k))
        end
      end
    end
  end
end
