require 'uri'
require 'json'
require 'rest-client'
require_relative './exception'
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
# Calling any of the call_ methods returns a Ruby object of the JSON
# data passed back by the API.
#
module Wavefront
  class Base
    attr_reader :opts, :debug, :noop, :verbose, :net

    def initialize(creds = {}, opts = {})
      @opts  = opts
      @debug = opts[:debug] || false
      @noop = opts[:noop] || false
      @verbose = opts[:verbose] || false
      setup_endpoint(creds)
    end

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

=begin
    def interpolate_schema(label, host, prefix_length)
      label_parts = label.split('.')
      interpolated = []
      interpolated << label_parts.shift(prefix_length)
      interpolated << host
      interpolated << label_parts
      interpolated.flatten!
      interpolated.join('.')
    end
=end

    def parse_time(t)
      #
      # Return a time as an integer, however it might come in.
      #
      return t if t.is_a?(Integer)
      return t.to_i if t.is_a?(Time)
      return t.to_i if t.is_a?(String) && t.match(/^\d+$/)
      DateTime.parse("#{t} #{Time.now.getlocal.zone}").to_time.utc.to_i
    rescue
      raise "cannot parse timestamp '#{t}'."
    end

    def time_to_ms(t)
      #
      # Return the time as milliseconds since the epoch
      #
      return false unless t.is_a?(Integer)
      (t.to_f * 1000).round
    end

    def build_uri(path, qs = nil)
      URI::HTTPS.build(
        host:  net[:endpoint],
        path:  [net[:api_base], path].uri_concat,
        query: qs
      )
    end

    def call_get(path, qs = nil)
      uri = build_uri(path, qs)

      if verbose || noop
        puts 'GET ' + uri.to_s
        puts 'HEADERS ' + net[:headers].to_s
      end

      return if noop

      JSON.parse(RestClient.get(uri.to_s, net[:headers]))
    end

    def call_post(uri, body = nil, ctype = 'text/plain')
      headers = net[:headers].merge(:'Content-Type' => ctype,
                                    :Accept         => 'application/json')

      uri = build_uri(uri)

      if verbose || noop
        puts 'POST ' + uri.to_s
        puts 'BODY ' + body if body
        puts 'HEADERS ' + headers.to_s
      end

      return if noop

      JSON.parse(RestClient.post(uri.to_s, body, headers))
    end

    def call_put(uri, body = nil, ctype = 'application/json')
      headers = net[:headers].merge(:'Content-Type' => ctype,
                                    :Accept         => 'application/json')

      uri = build_uri(uri)
      body = body.to_json

      if verbose || noop
        puts 'PUT ' + uri.to_s
        puts 'BODY ' + body if body
        puts 'HEADERS ' + headers.to_s
      end

      return if noop

      JSON.parse(RestClient.put(uri.to_s, body, headers))
    end

    def call_delete(uri)
      uri = build_uri(uri)

      if verbose || noop
        puts 'DELETE ' + uri.to_s
        puts 'HEADERS ' + net[:headers].to_s
      end

      return if noop

      JSON.parse(RestClient.delete(uri.to_s, net[:headers]))
    end

    def debug(msg)
      puts "DEBUG: #{msg}" if debug
    end
  end
end

class Hash
  def to_qs
    #
    # Make a properly escaped query string out of a key: value
    # hash.
    #
    URI.escape(self.map { |k, v| [k, v].join('=') }.join('&'))
  end
end

class Array
  def uri_concat
    self.join('/').squeeze('/').sub(/\/$/, '')
  end
end
