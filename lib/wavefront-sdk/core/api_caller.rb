# frozen_string_literal: true

require 'json'
require 'faraday'
require 'addressable'
require_relative 'response'
require_relative '../defs/version'
require_relative '../support/mixins'
require_relative '../stdlib/time'

module Wavefront
  #
  # Constructs and makes API calls to Wavefront.
  #
  class ApiCaller
    include Wavefront::Mixins

    attr_reader :opts, :noop, :debug, :verbose, :net, :logger, :calling_class

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
    # @param path [String] uri path
    # @param headers [Hash] additional headers
    # @param request_opts [Hash] Faraday request parameters
    # @return [URI::HTTPS]
    #
    def mk_conn(path, headers = {}, opts = {})
      url = format('%<scheme>s://%<endpoint>s%<path>s',
                   scheme: net[:scheme],
                   endpoint: net[:endpoint],
                   path: [net[:api_base], path].uri_concat)
      set_opts = { url: Addressable::URI.encode(url),
                   headers: net[:headers].merge(headers) }
      Faraday.new(set_opts.merge(opts))
    end

    # Make a GET call to the Wavefront API and return the result as
    # a Ruby hash.
    #
    # @param path [String] path to be appended to the
    #   #net[:api_base] path.
    # @param query [Hash] optional key-value pairs with will be made
    #   into a query string
    # @param request_opts [Hash] parameters to pass through to
    #   Faraday
    # @return [Hash] API response
    #
    def get(path, query = {})
      make_call(mk_conn(path, {}), :get, nil, query)
    end

    # Had to introduce this for the Wavefront::Dashboard#acls
    # method, which uses a query string of multiple id=s. By default
    # Faraday only uses the last one. You must set the
    # `params_encoder`. Rather than convolute the existing logic, it
    # was cleaner to add this method. Parameters are same as #get.
    #
    def get_flat_params(path, query = {})
      make_call(flat_param_conn(path, query), :get)
    end

    # This is used by the Wavefront::Unstable::Spy methods to stream data.
    # It prints to standard out.
    # @param path [String] path to be appended to the net[:api_base] path.
    # @param query [Hash] optional key-value pairs with will be made into a
    #   query string
    # @param opts [Hash] keys:
    #   timestamp_chunks -- prints a timestamp before each chunk of streamed
    #     data
    #   timeout -- after approximately this many seconds, return. It will be
    #     the first chunk *after* the given time
    # @return
    #
    def get_stream(path, query = {}, opts = {})
      conn = flat_param_conn(path, query)
      verbosity(conn, :get, query)
      stream_connection(conn, query, opts)
    rescue Faraday::TimeoutError
      raise Wavefront::Exception::NetworkTimeout
    rescue StopIteration
      nil
    end

    def stream_connection(conn, query, opts)
      t_end = end_time(opts)

      conn.get do |req|
        req.params = query
        req.options.on_data = proc do |chunk, _size|
          raise StopIteration if t_end && Time.right_now >= t_end

          puts Time.now if opts[:timestamp_chunks]
          puts chunk
        end
      end
    end

    def end_time(opts)
      Time.right_now + opts[:timeout] if opts[:timeout]&.positive?
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
                               Accept: 'application/json'),
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
                               Accept: 'application/json'),
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
    # @param resp [Faraday::Response]
    # @return [String] body of response (JSON)
    #
    def respond(resp)
      body = if calling_class.respond_to?(:response_shim)
               calling_class.response_shim(resp.body, resp.status)
             else
               resp.body
             end

      return body if opts[:raw_response]

      Wavefront::Response.new(body, resp.status, opts)
    end

    # Try to describe the actual HTTP calls we make. There's a bit
    # of clumsy guesswork here
    #
    def verbosity(conn, method, *args)
      return unless noop || verbose

      log format('uri: %<method>s %<path>s',
                 method: method.upcase,
                 path: conn.url_prefix)

      return unless args.last && !args.last.empty?

      log method == :get ? "params: #{args.last}" : "body: #{args.last}"
    end

    private

    def paginator_class(method)
      require_relative File.join('..', 'paginator', method.to_s)
      Object.const_get(format('Wavefront::Paginator::%<method>s',
                              method: method.to_s.capitalize))
    end

    # A dispatcher for making API calls. We now have three methods
    # that do the real call, two of which live inside the requisite
    # Wavefront::Paginator class
    # @raise [Faraday::ConnectionFailed] if cannot connect to
    #   endpoint
    #
    def make_call(conn, method, *args)
      paginator = paginator_class(method).new(self, conn, method, *args)

      case paginator.initial_limit
      when :all, 'all'
        paginator.make_recursive_call
      when :lazy, 'lazy'
        paginator.make_lazy_call
      else
        make_single_call(conn, method, *args)
      end
    end

    def make_single_call(conn, method, *args)
      verbosity(conn, method, *args)
      return if noop

      pp args if debug

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

      @net = { headers: headers(creds),
               scheme: opts[:scheme] || 'https',
               endpoint: creds[:endpoint],
               api_base: calling_class.api_path }
    end

    def headers(creds)
      ret = { 'user-agent': creds[:agent] }
      ret[:Authorization] = "Bearer #{creds[:token]}" if creds[:token]
      ret
    end

    def validate_credentials(creds)
      if calling_class.respond_to?(:validate_credentials)
        calling_class.validate_credentials(creds)
      else
        _validate_credentials(creds)
      end
    end

    def _validate_credentials(creds)
      %w[endpoint token].each do |k|
        unless creds.key?(k.to_sym)
          raise(Wavefront::Exception::CredentialError,
                format('credentials must contain %<key>s', key: k))
        end
      end
    end

    def flat_param_conn(path, query)
      mk_conn(path,
              {},
              request: {
                params_encoder: Faraday::FlatParamsEncoder
              },
              params: query)
    end
  end
end
