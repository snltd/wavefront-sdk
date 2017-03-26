require_relative './base'

module Wavefront
  class Alert < Wavefront::Base

    def list(offset = 0, limit = 100)
      api_get('', { offset: offset, limit: limit }.to_qs)
    end

    def describe(id)
      api_get(id)
    end

    def delete(id)
      api_delete(id)
    end

    def undelete(id)
      api_post([id, 'undelete'].uri_concat)
    end

    def history(id, version = nil)
      fragments = [id, 'history']
      fragments.<< version.to_s if version
      api_get(fragments.uri_concat)
    end

    def summary
      api_get('summary')
    end
  end
end

=begin

require 'rest_client'
require 'uri'
require 'logger'
require_relative './base'

module Wavefront
  class Alert < Wavefront::Base
    DEFAULT_PATH = '/api/alert/'

    attr_reader :token, :noop, :verbose, :endpoint, :headers, :options

    def initialize(token, host = DEFAULT_HOST, debug=false, options = {})
      #
      # Following existing convention, 'host' is the Wavefront API endpoint.
      #
      @headers = { :'X-AUTH-TOKEN' => token }
      @endpoint = host
      @token = token
      debug(debug)
      @noop = options[:noop]
      @verbose = options[:verbose]
      @options = options
    end

    def import_to_create(raw)
      #
      # Take a previously exported alert, and construct a hash which
      # create_alert() can use to re-create it.
      #
      ret = {
        name:          raw['name'],
        condition:     raw['condition'],
        minutes:       raw['minutes'],
        notifications: raw['target'].split(','),
        severity:      raw['severity'],
      }

      if raw.key?('displayExpression')
        ret[:displayExpression] = raw['displayExpression']
      end

      if raw.key?('resolveAfterMinutes')
        ret[:resolveMinutes] = raw['resolveAfterMinutes']
      end

      if raw.key?('customerTagsWithCounts')
        ret[:sharedTags] = raw['customerTagsWithCounts'].keys
      end

      if raw.key?('additionalInformation')
        ret[:additionalInformation] = raw['additionalInformation']
      end

      ret
    end

    def create_alert(alert={})
      #
      # Create an alert. Expects you to provide it with a hash of
      # the form:
      #
      # {
      #   name:                 string
      #   condition:            string
      #   displayExpression:    string     (optional)
      #   minutes:              int
      #   resolveMinutes:       int        (optional)
      #   notifications:        array
      #   severity:             INFO | SMOKE | WARN | SEVERE
      #   privateTags:          array      (optional)
      #   sharedTags:           array      (optional)
      #   additionalInformation string     (optional)
      # }
      #
      %w(name condition minutes notifications severity).each do |f|
        raise "missing field: #{f}" unless alert.key?(f.to_sym)
      end

      unless %w(INFO SMOKE WARN SEVERE).include?(alert[:severity])
        raise 'invalid severity'
      end

      %w(notifications privateTags sharedTags).each do |f|
        f = f.to_sym
        alert[f] = alert[f].join(',') if alert[f] && alert[f].is_a?(Array)
      end

      call_post(create_uri(path: 'create'),
                hash_to_qs(alert), 'application/x-www-form-urlencoded')
    end

    def get_alert(id, options = {})
      #
      # Alerts are identified by the timestamp at which they were
      # created. Returns a hash. Exceptions are just passed on
      # through. You get a 500 if the alert doesn't exist.
      #
      resp = call_get(create_uri(path: id)) || '{}'
      return JSON.parse(resp)
    end

    def active(options={})
      call_get(create_uri(options.merge(path: 'active',
                                        qs: mk_qs(options))))
    end

    def all(options={})
      call_get(create_uri(options.merge(path: 'all', qs: mk_qs(options))))
    end

    def invalid(options={})
      call_get(create_uri(options.merge(path: 'invalid',
                                        qs: mk_qs(options))))
    end

    def snoozed(options={})
      call_get(create_uri(options.merge(path: 'snoozed',
                                        qs: mk_qs(options))))
    end

    def affected_by_maintenance(options={})
      call_get(create_uri(options.merge(path: 'affected_by_maintenance',
                                        qs: mk_qs(options))))
    end

    private

    def list_of_tags(t)
      t.is_a?(Array) ? t : [t]
    end

    def mk_qs(options)
      query = []

      if options[:shared_tags]
        query.push(list_of_tags(options[:shared_tags]).map do |t|
          "customerTag=#{t}"
        end.join('&'))
      end

      if options[:private_tags]
        query.push(list_of_tags(options[:private_tags]).map do |t|
          "userTag=#{t}"
        end.join('&'))
      end

      query.join('&')
    end

    def create_uri(options = {})
      #
      # Build the URI we use to send a 'create' request.
      #
      options[:host] ||= endpoint
      options[:path] ||= ''
      options[:qs]   ||= nil

      options[:qs] = nil if options[:qs] && options[:qs].empty?

      URI::HTTPS.build(
        host:  options[:host],
        path:  [DEFAULT_PATH, options[:path]].uri_concat,
        query: options[:qs],
      )
    end

    def debug(enabled)
      RestClient.log = 'stdout' if enabled
    end
  end
end

=end
