require 'uri'
require 'json'
require 'time'
require 'rest-client'
require_relative './exception'
require_relative './validators'
#
# base.rb
#
# All API classes inherit from this class. To create an API object
# you must pass in a credential object of the following form
#
# {
#   endpoint: uri,
#   token:    string
# }
#
# Calling any of the api_ methods returns a Ruby object of the JSON
# data passed back by the API.
#
module Wavefront
  class Base
    include Wavefront::Validators
    attr_reader :opts, :debug, :noop, :verbose, :net

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
    # @return [Integer] epoch time in seconds
    # @raise Wavefront::InvalidTimestamp
    #
    def parse_time(t)
      return t if t.is_a?(Integer)
      return t.to_i if t.is_a?(Time)
      return t.to_i if t.is_a?(String) && t.match(/^\d+$/)
      DateTime.parse("#{t} #{Time.now.getlocal.zone}").to_time.utc.to_i
    rescue
      raise Wavefront::Exception::InvalidTimestamp
    end

    # Convert an epoch timestamp into epoch milliseconds.
    #
    # @param t [Integer] epoch timestamp
    # @return [Ingeter] epoch millisecond timestamp
    #
    def time_to_ms(t)
      return false unless t.is_a?(Integer)
      (t.to_f * 1000).round
    end

    # Create a HTTPS URI. The server comes from the endpoint passed
    # to the initializer in the 'creds' hash; the root of the URI
    # is dynamically derived by the #setup_endpoint method.
    #
    # @param path [String] path to append to the #net[:api_base]
    #   path.
    # @param qs [String] optinal query string
    # @return [URI::HTTPS]
    #
    def build_uri(path, qs = nil)
      URI::HTTPS.build(host:  net[:endpoint],
                       path:  [net[:api_base], path].uri_concat,
                       query: qs)
    end

    # Make a GET call using an object automatically created by
    # #build_uri, and return the result as a Ruby hash. Can
    # optionally perform a verbose noop, if the #noop class variable
    # is set. If #verbose is set, then prints the information used
    # to build the URI.
    #
    # @param path [String] path to be appended to the
    #   #net[:api_base] path.
    # @param qs [String] optional query string
    # @return [Hash] API response
    #
    def api_get(path, qs = nil)
      uri = build_uri(path, qs)

      if verbose || noop
        msg('GET', uri)
        msg('HEADERS', net[:headers])
      end

      return if noop

      JSON.parse(RestClient.get(uri.to_s, net[:headers]) || {})
    end

    # Make a POST call using an object automatically created by
    # #build_uri, and return the result as a Ruby hash. Can
    # optionally perform a verbose noop, if the #noop class variable
    # is set. If #verbose is set, then prints the information used
    # to build the URI.
    #
    # @param path [String] path to be appended to the
    #   #net[:api_base] path.
    # @param body [String] optional body text to post
    # @param ctype [String] the content type to use when posting
    # @return [Hash] API response
    #
    def api_post(path, body = nil, ctype = 'text/plain')
      headers = net[:headers].merge(:'Content-Type' => ctype,
                                    :Accept         => 'application/json')
      uri = build_uri(path)

      if verbose || noop
        msg('POST', uri)
        msg('BODY', body) if body
        msg('HEADERS', headers)
      end

      return if noop

      JSON.parse(RestClient.post(uri.to_s, body, headers) || {})
    end

    # Make a PUT call using an object automatically created by
    # #build_uri, and return the result as a Ruby hash. Can
    # optionally perform a verbose noop, if the #noop class variable
    # is set. If #verbose is set, then prints the information used
    # to build the URI.
    #
    # @param path [String] path to be appended to the
    #   #net[:api_base] path.
    # @param body [String] optional body text to post
    # @param ctype [String] the content type to use when putting
    # @return [Hash] API response
    #
    def api_put(path, body = nil, ctype = 'application/json')
      headers = net[:headers].merge(:'Content-Type' => ctype,
                                    :Accept         => 'application/json')

      uri = build_uri(path)
      body = body.to_json

      if verbose || noop
        msg('PUT', uri)
        msg('BODY', body) if body
        msg('HEADERS', headers)
      end

      return if noop

      JSON.parse(RestClient.put(uri.to_s, body, headers))
    end

    # Make a DELETE call using an object automatically created by
    # #build_uri, and return the result as a Ruby hash. Can
    # optionally perform a verbose noop, if the #noop class variable
    # is set. If #verbose is set, then prints the information used
    # to build the URI.
    #
    # @param path [String] path to be appended to the
    #   #net[:api_base] path.
    # @return [Hash] API response
    #
    def api_delete(path)
      uri = build_uri(path)

      if verbose || noop
        msg('DELETE', uri)
        msg('HEADERS', net[:headers])
      end

      return if noop

      JSON.parse(RestClient.delete(uri.to_s, net[:headers]))
    end

    private

    def setup_endpoint(creds)
      %w(endpoint token).each do |k|
        raise "creds must contain #{k}" unless creds.key?(k.to_sym)
      end

      @net = {
        headers:  { 'Authorization' => "Bearer #{creds[:token]}" },
        endpoint: creds[:endpoint],
        api_base: ['', 'api', 'v2',
                   self.class.name.split('::').last.downcase].uri_concat
      }
    end

    def msg(*msg)
      puts msg.map { |m| m.to_s }.join(' ')
    end
  end
end

class Hash

  # Make a properly escaped query string out of a key: value hash.
  #
  def to_qs
    URI.encode(self.map { |k, v| [k, v].join('=') }.join('&'))
  end
end

class Array

  # Join strings together to make a URI path in a way that is more
  # flexible than URI::Join.  Removes multiple and trailing
  # separators. Does not have to produce fully qualified paths. Has
  # no concept of protocols, hostnames, or query strings.
  #
  # @return [String] a URI path
  #
  def uri_concat
    URI.encode(self.join('/').squeeze('/').sub(/\/$/, ''))
  end
end
