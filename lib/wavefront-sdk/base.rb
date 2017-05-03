require 'json'
require 'time'
require 'faraday'
require_relative './exception'
require_relative './validators'
require_relative './version'

module Wavefront
  #
  # Abstract class from which all API classes inherit.
  #
  class Base
    include Wavefront::Validators
    attr_reader :opts, :debug, :noop, :verbose, :net, :api_base, :conn

    # Create a new API object. This will always be called from a
    # class which inherits this one.
    #
    # @param creds [Hash] must contain the keys `endpoint` (the
    #   Wavefront API server) and `token`, the user token with which
    #   you wish to access the endpoint.
    # @param opts [Hash] options governing class behaviour. Expected
    #   keys are `debug`, `noop` and `verbose`, all boolean.
    # @return [Nil]
    #
    def initialize(creds = {}, opts = {})
      @opts  = opts
      @debug = opts[:debug] || false
      @noop = opts[:noop] || false
      @verbose = opts[:verbose] || false
      setup_endpoint(creds)
    end

    # Return a time as an integer, however it might come in.
    #
    # @param t [Integer, String, Time] timestamp
    # @param ms [Boolean] whether to return epoch milliseconds
    # @return [Integer] epoch time in seconds
    # @raise Wavefront::InvalidTimestamp
    #
    def parse_time(t, ms = false)
      #
      # Numbers, or things that look like numbers, pass straight
      # through. No validation, because maybe the user means one
      # second past the epoch, or the year 2525.
      #
      return t if t.is_a?(Integer)

      if t.is_a?(String)
        return t.to_i if t.match(/^\d+$/)
        begin
          t = DateTime.parse("#{t} #{Time.now.getlocal.zone}")
        rescue
          raise Wavefront::Exception::InvalidTimestamp
        end
      end

      ms ? t.to_datetime.strftime('%Q').to_i : t.strftime('%s').to_i
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
    def mk_conn(method, path, headers = {})
      if verbose || noop
        msg(method.upcase,
            net[:endpoint] + [net[:api_base], path].uri_concat)
        msg('HEADERS', net[:headers])
      end

      return false if noop

      Faraday.new(
        url:     net[:endpoint] + [net[:api_base], path].uri_concat,
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
      conn = mk_conn(:get, path)
      return if noop
      JSON.parse(conn.get(nil, query).body || {})
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
      conn = mk_conn(:post, path, { 'Content-Type': ctype,
                                    'Accept': 'application/json'})
      body = body.to_json unless body.is_a?(String)
      msg('BODY', body) if body && (verbose || noop)
      return if noop
      JSON.parse(conn.post(nil, body).body || {})
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
      conn = mk_conn(:put, path, { 'Content-Type': ctype,
                                   'Accept': 'application/json' })
      body = body.to_json
      msg('BODY', body) if body && (verbose || noop)
      return if noop
      JSON.parse(conn.put(nil, body).body || {})
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
      conn = mk_conn(:delete, path)
      return if noop
      JSON.parse(conn.delete.body || {})
    end

    private

    def setup_endpoint(creds)
      %w(endpoint token).each do |k|
        raise "creds must contain #{k}" unless creds.key?(k.to_sym)
      end

      @net = {
        headers:  { 'Authorization': "Bearer #{creds[:token]}",
                    'user-agent':    "wavefront-sdk #{WF_SDK_VERSION}",
                  },
        endpoint: creds[:endpoint],
        api_base: ['', 'api', 'v2', api_base].uri_concat
      }
    end

    def msg(*msg)
      puts msg.map(&:to_s).join(' ')
    end
  end
end

# Extensions to stdlib Array
#
class Array

  # Join strings together to make a URI path in a way that is more
  # flexible than URI::Join.  Removes multiple and trailing
  # separators. Does not have to produce fully qualified paths. Has
  # no concept of protocols, hostnames, or query strings.
  #
  # @return [String] a URI path
  #
  def uri_concat
    URI.encode(self.join('/').squeeze('/').sub(/\/$/, '').sub(/\/\?/, '?'))
  end
end
