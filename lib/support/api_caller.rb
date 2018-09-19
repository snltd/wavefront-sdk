require 'json'
require 'faraday'
require 'addressable'
require_relative 'mixins'
require_relative 'response'
require_relative '../wavefront-sdk/version'

module Wavefront
  #
  # Constructs and makes API calls to Wavefront.
  #
  class ApiCaller
    include Wavefront::Mixins

    attr_reader :noop, :debug, :verbose, :net, :logger, :calling_class,
                :page_size

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
      @page_size = opts[:page_size] || 999
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
    def get(path, query = {})
      make_call(mk_conn(path), :get, nil, query)
    end

    # Make a POST call to the Wavefront API and return the result as
    # a Ruby hash. Can optionally perform a verbose noop, if the
    # @noop class variable is set. If @verbose is set, then prints
    # the information used to build the URI.
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
    def put(path, body = nil, ctype = 'application/json')
      body = body.to_json unless body.is_a?(String)
      make_call(mk_conn(path,  'Content-Type': ctype,
                               'Accept': 'application/json'),
                :put, nil, body)
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

    # @param limit [Integer] desired value of limit
    # @param offset [Integer] desired value of offset
    # @param args [Array] arguments to pass to Faraday.get
    #
    def set_pagination(offset, limit, args)
       args.map do |arg|
        arg.tap do |a|
          if a.is_a?(Hash) && a.key?(:limit) && a.key?(:offset)
            a[:limit] = limit
            a[:offset] = offset
          end
        end
      end
    end

    # 'get' eagerly. Re-run the get operation, merging together
    # returned items until we have them all.
    # @param conn [Faraday::Connection]
    # @param *args arguments to pass to Faraday's #get method
    # @return [Wavefront::Response]
    #
    def make_recursive_call(conn, method, *args)
      offset = 0
      page_size = chunk_size(args)
      puts "page size is #{page_size}"
      args = set_pagination(offset, page_size, args)
      ret = respond(conn.public_send(method, *args))

      return ret unless ret.more_items?

      loop do
        offset += page_size
        puts "looping on #{offset}"
        args = set_pagination(offset, page_size, args)
        resp = respond(conn.public_send(method, *args))
        ret.response.items += resp.response.items
        raise StopIteration unless resp.more_items?
      end

      ret
    end

    # How many objects to get on each iteration? The user can pass
    # it in as an alternative to the offset argument, and we can
    # also take it from the page_size class variable. If it's zero,
    # default to page_size, and if it's still zero, fall back to
    # 999.
    #
    def chunk_size(args)
      arg_val = limit_and_offset(args)[:offset]
      puts "arg_val --> #{arg_val}"
      return arg_val if arg_val > 0
      return page_size if page_size > 0
      999
    end

    # Return all objects using a lazy enumerator. You can pass in
    # the page size as the offset argument
    # @return [Enumerable]
    #
    def make_lazy_call(conn, method, *args)
      offset = 0
      page_size = chunk_size(args)
      args = set_pagination(offset, page_size, args)

      Enumerator.new do |y|
        loop do
          offset += page_size
          resp = respond(conn.public_send(method, *args))
          args = set_pagination(offset, page_size, args)
          resp.response.items.map { |i| y.<< i }
          raise StopIteration unless resp.more_items?
        end
      end.lazy
    end

    # A dispatcher for making API calls. We now have three methods
    # that do the real call.
    #
    def make_call(conn, method, *args)
      verbosity(conn, method, *args) if noop || verbose
      return if noop

      case limit_and_offset(args)[:limit].to_sym
      when :all
        puts "making recursive"
        make_recursive_call(conn, method, *args)
      when :lazy
        puts "making lazy"
        make_lazy_call(conn, method, *args)
      else
        puts "making single"
        make_single_call(conn, method, *args)
      end
    end

    # An API call may or may not have a limit and/or offset value.
    # They could (I think) be anywhere. Safely find and return them
    #
    # @param args [Array] arguments to be passed to a Faraday
    #   connection object
    # @return [Array] [offset, limit] either can be nil
    #
    def limit_and_offset(args)
      ret = { offset: page_size, limit: nil }

      args.select { |a| a.is_a?(Hash) }.each do |arg|
        ret[:limit] = arg.fetch(:limit, nil)
        ret[:offset] = arg.fetch(:offset, page_size)
      end

      ret
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

  class ApiCallerPost < ApiCaller
    # The limit and offset are in the second arg
    #
    def set_pagination(offset, limit, args)
      body = JSON.parse(args[1], symbolize_names: true)
      new_args = args.dup
      new_args[1] = body
      munged_args = super(offset, limit, new_args)
      stringed_body = munged_args[1].to_json
      new_args[1] = stringed_body
      new_args
    end

    # The body is the second argument, and it may have a limit and
    # offset inside.
    #
    def limit_and_offset(args)
      super([JSON.parse(args[1], symbolize_names: true)])
    end
  end
end
