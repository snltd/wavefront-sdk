require 'rest_client'
require 'uri'
require 'logger'
require_relative './exception'
require_relative './base'

module Wavefront
  #
  # Wrappers around the v1 dashboards API
  #
  class Dashboard < Wavefront::Base
    DEFAULT_PATH = '/api/dashboard/'.freeze

    attr_reader :headers, :noop, :verbose, :endpoint

    def initialize(token, host = DEFAULT_HOST, debug = false, options = {})
      #
      # Following existing convention, 'host' is the Wavefront API endpoint.
      #
      @headers = { :'X-AUTH-TOKEN' => token }
      @endpoint = host
      debug(debug)
      @noop = options[:noop]
      @verbose = options[:verbose]
    end

    def import(schema, force = false)
      #
      # Imports a dashboard described as a JSON string (schema)
      #
      qs = force ? nil : 'rejectIfExists=true'
      call_post(create_uri(qs: qs), schema, 'application/json')
    end

    def clone(source_id, dest_id, dest_name, source_ver = nil)
      #
      # Clone a dashboard. If source_ver is not truthy, the latest
      # version of the source is used.
      #
      qs = hash_to_qs(name: dest_name, url: dest_id)
      qs.<< "&v=#{source_ver}" if source_ver

      call_post(create_uri(path: uri_concat(source_id, 'clone')), qs,
                'application/x-www-form-urlencoded')
    end

    def history(id, start = 100, limit = nil)
      qs = "start=#{start}"
      qs.<< "&limit=#{limit}" if limit

      call_get(create_uri(path: uri_concat(id, 'history'), qs: qs))
    end

    def list(opts = {})
      qs = []

      opts[:private].map { |t| qs.<< "userTag=#{t}" } if opts[:private]
      opts[:shared].map { |t| qs.<< "customerTag=#{t}" } if opts[:shared]

      call_get(create_uri(qs: qs.join('&')))
    end

    def undelete(id)
      call_post(create_uri(path: uri_concat(id, 'undelete')))
    end

    def delete(id)
      call_post(create_uri(path: uri_concat(id, 'delete')))
    end

    def export(id, version = nil)
      path = version ? uri_concat(id, version) : id
      resp = call_get(create_uri(path: path)) || '{}'
      JSON.parse(resp)
    end

    def create(id, name)
      call_post(create_uri(path: uri_concat([id, 'create'])),
                "name=#{URI.encode(name)}",
                'application/x-www-form-urlencoded')
    end

    def create_uri(options = {})
      #
      # Build the URI we use to send a 'create' request.
      #
      options[:host] ||= endpoint
      options[:path] ||= ''
      options[:qs]   ||= nil

      URI::HTTPS.build(
        host:  options[:host],
        path:  uri_concat(DEFAULT_PATH, options[:path]),
        query: options[:qs]
      )
    end

    def debug(enabled)
      RestClient.log = 'stdout' if enabled
    end
  end
end
