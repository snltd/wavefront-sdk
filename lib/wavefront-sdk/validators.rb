# rubocop:disable Naming/UncommunicativeMethodParamName
require_relative './constants'
require_relative './exception'

module Wavefront
  #
  # A module of mixins to validate input. The Wavefront documentation
  # lays down restrictions on types and sizes of various inputs, which
  # we will check on the user's behalf. Most of the information used in
  # this file comes from https://community.wavefront.com/docs/DOC-1031
  # Some comes from the Swagger API documentation, some has come
  # directly from Wavefront engineers.
  #
  # rubocop:disable Metrics/ModuleLength
  module Validators
    # Ensure the given argument is a valid external link template
    #
    # @return true if it is valid
    # @raise Wavefront::Exception::InvalidTemplate if not
    #
    def wf_link_template?(v)
      return true if v.is_a?(String) && v.start_with?('http://', 'https://')

      raise Wavefront::Exception::InvalidLinkTemplate
    end

    # Ensure the given argument is a valid Wavefront metric name, or
    # path.
    #
    # @param v [String] the metric name to validate
    # @return True if the metric name is valid
    # @raise Wavefront::Exception::InvalidMetricName if metric name
    # is not valid.
    #
    def wf_metric_name?(v)
      if v.is_a?(String) && v.size < 1024 &&
         (v.match(/^#{DELTA}?[\w\-\.]+$/) ||
          v.match(%r{^\"#{DELTA}?[\w\-\.\/,]+\"$}))
        return true
      end

      raise Wavefront::Exception::InvalidMetricName
    end

    # Ensure the given argument is a valid name, for instance for an
    # event. Names can contain, AFAIK, word characters.
    #
    # @param v [String] the name to validate
    # @return true if the name is valid
    # raise Wavefront::Exception::InvalidName if name is not valid
    #
    def wf_name?(v)
      return true if v.is_a?(String) && v.size < 1024 && v =~ /^\w+$/
      raise Wavefront::Exception::InvalidName
    end

    # Ensure the given argument is a valid string, for a tag name.
    #
    # @param v [String] the string name to validate
    # @return True if the string is valid
    # @raise Wavefront::Exception::InvalidString if string is not valid.
    #
    def wf_string?(v)
      #
      # Only allows PCRE "word" characters, spaces, full-stops and
      # commas in tags and descriptions. This might be too restrictive,
      # but if it is, this is the only place we need to change it.
      #
      return true if v.is_a?(String) && v.size < 1024 && v =~ /^[\-\w \.,]*$/

      raise Wavefront::Exception::InvalidString
    end

    # Ensure the given argument is a valid timestamp
    #
    # @param v [DateTime] the timestamp name to validate
    # @return True if the value is valid
    # @raise Wavefront::Exception::InvalidTimestamp
    #
    def wf_ts?(v)
      return true if v.is_a?(Time) || v.is_a?(Date)
      raise Wavefront::Exception::InvalidTimestamp
    end

    # Ensure the given argument is a valid millisecond epoch
    # timestamp. We do no checking of the value, because who am I to
    # say that the user doesn't want to send a point relating to 1ms
    # after the epoch, or a thousand years in the future?
    #
    # @param v [Integer] the timestamp name to validate
    # @return True if the value is valid
    # @raise Wavefront::Exception::InvalidTimestamp
    #
    def wf_ms_ts?(v)
      return true if v.is_a?(Numeric)
      raise Wavefront::Exception::InvalidTimestamp
    end

    # Ensure the given argument is a valid epoch timestamp. Again,
    # no range checking.
    #
    # @param v [String, Integer]
    # @return True if the timestamp is valid
    # @raise Wavefront::Exception::InvalidMaintenanceWindow
    #
    def wf_epoch?(v)
      return true if v.is_a?(Numeric)
      raise Wavefront::Exception::InvalidTimestamp
    end

    # Ensure one, or an array, of tags are valid. These tags are
    # used as source tags, or tags for maintenance windows etc. They
    # can contain letters, numbers, -, _ and :, and must be less
    # than 256 characters long
    #
    # @param v [String, Array] a tag or list of tags
    # @return True if all tags are valid
    # @raise Wavefront::Exception::InvalidTag
    #
    def wf_tag?(*v)
      Array(*v).each do |t|
        unless t.is_a?(String) && t.size < 255 && t =~ /^[\w:\-\.]+$/
          raise Wavefront::Exception::InvalidTag
        end
      end

      true
    end

    # Ensure the given argument is a valid Wavefront value. Can be
    # any form of Numeric, including standard notation.
    #
    # @param v [Numeric] the source name to validate
    # @return True if the value is valid
    # @raise Wavefront::Exception::InvalidValue if the value is not valid
    #
    def wf_value?(v)
      return true if v.is_a?(Numeric)
      raise Wavefront::Exception::InvalidMetricValue
    end

    # Ensure the given argument is a valid version number
    #
    # @param v [Integer] the version number to validate
    # @return True if the version is valid
    # @raise Wavefront::Exception::InvalidVersion if the alert ID is
    #   not valid
    #
    # rubocop:disable Style/NumericPredicate
    def wf_version?(v)
      v = v.to_i if v.is_a?(String) && v =~ /^\d+$/
      return true if v.is_a?(Integer) && v > 0
      raise Wavefront::Exception::InvalidVersion
    end
    # rubocop:enable Style/NumericPredicate

    # Ensure a hash of key:value point tags are value. Not to be
    # confused with source tags.
    #
    # @param tags [Hash] a hash of key:value tags
    # @return True if all tags are valid
    # @raise Wavefront::Exception::InvalidTag if any tags in the has
    #   do not validate
    #
    def wf_point_tags?(tags)
      raise Wavefront::Exception::InvalidTag unless tags.is_a?(Hash)
      tags.each { |k, v| wf_point_tag?(k, v) }
    end

    # Validate a single point tag, probably on behalf of
    # #wf_point_tags?
    # @param k [String] tag key
    # @param v [String] tag value
    # @raise Wavefront::Exception::InvalidTag if any tag is not valid
    # @return nil
    #
    def wf_point_tag?(k, v)
      return if k && v && (k.size + v.size < 254) && k =~ /^[\w\-\.:]+$/
      raise Wavefront::Exception::InvalidTag
    end

    # Ensure the given argument is a valid Wavefront proxy ID
    #
    # @param v [String] the proxy ID to validate
    # @return True if the proxy ID is valid
    # @raise Wavefront::Exception::InvalidProxyId if the proxy ID
    #   is not valid
    #
    def wf_proxy_id?(v)
      if v.is_a?(String) && v.match(
        /^[a-f0-9]{8}-[a-f0-9]{4}-[a-f0-9]{4}-[a-f0-9]{4}-[a-f0-9]{12}$/
      )
        return true
      end

      raise Wavefront::Exception::InvalidProxyId
    end

    # Ensure the given argument is a valid Wavefront alert ID.
    # Alerts are identified by the epoch-nanosecond at which they
    # were created.
    #
    # @param v [String] the alert ID to validate
    # @return True if the alert ID is valid
    # @raise Wavefront::Exception::InvalidAlertId if the alert ID is
    #   not valid
    #
    def wf_alert_id?(v)
      v = v.to_s if v.is_a?(Numeric)
      return true if v.is_a?(String) && v.match(/^\d{13}$/)
      raise Wavefront::Exception::InvalidAlertId
    end

    # Ensure the given argument is a valid Wavefront cloud
    # integration ID
    #
    # @param v [String] the integration name to validate
    # @return True if the integration name is valid
    # @raise Wavefront::Exception::InvalidCloudIntegrationId if the
    #   integration ID is not valid
    #
    def wf_cloudintegration_id?(v)
      if v.is_a?(String) && v.match(
        /^[a-f0-9]{8}-[a-f0-9]{4}-[a-f0-9]{4}-[a-f0-9]{4}-[a-f0-9]{12}$/
      )
        return true
      end

      raise Wavefront::Exception::InvalidCloudIntegrationId
    end

    # There doesn't seem to be a public statement on what's allowed
    # in a dashboard name. For now I'm going to assume up to 255 word
    # characters.
    #
    # @param v [String] the dashboard ID to validate
    # @return true if the dashboard ID is valid
    # @raise Wavefront::Exception::InvalidDashboardID if the
    #   dashboard ID is not valid
    #
    def wf_dashboard_id?(v)
      return true if v.is_a?(String) && v.size < 256 && v.match(/^[\w\-]+$/)
      raise Wavefront::Exception::InvalidDashboardId
    end

    # Ensure the given argument is a valid event ID. Event IDs are
    # an epoch-millisecond timestamp followed by a : followed by the
    # name of the event.
    #
    # @param v [String] the event ID to validate
    # @return true if the event ID is valid
    # @raise Wavefront::Exception::InvalidEventID if the
    #   event ID is not valid
    #
    def wf_event_id?(v)
      return true if v.is_a?(String) && v =~ /^\d{13}:.+/
      raise Wavefront::Exception::InvalidEventId
    end

    # Ensure the given argument is a valid external Link ID
    #
    # @param v [String] the external link ID to validate
    # @return True if the link ID is valid
    # @raise Wavefront::Exception::InvalidExternalLinkId if the
    #   link ID is not valid
    #
    def wf_link_id?(v)
      return true if v.is_a?(String) && v =~ /^\w{16}$/
      raise Wavefront::Exception::InvalidExternalLinkId
    end

    # Ensure the given argument is a valid maintenance window ID.
    # IDs are the millisecond epoch timestamp at which the window
    # was created.
    #
    # @param v [String, Integer]
    # @return True if the ID is valid
    # @raise Wavefront::Exception::InvalidMaintenanceWindowId
    #
    def wf_maintenance_window_id?(v)
      v = v.to_s if v.is_a?(Numeric)
      return true if v.is_a?(String) && v =~ /^\d{13}$/

      raise Wavefront::Exception::InvalidMaintenanceWindowId
    end

    # Ensure the given argument is a valid alert severity
    #
    # @param v [String] severity
    # @return true if valid
    # @raise Wavefront::Exceptions::InvalidAlertSeverity if not
    #   valid
    #
    def wf_alert_severity?(v)
      return true if %w[INFO SMOKE WARN SEVERE].include?(v)
      raise Wavefront::Exception::InvalidAlertSeverity
    end

    # Ensure the given argument is a valid message ID
    #
    # @param v [String] severity
    # @return true if valid
    # @raise Wavefront::Exceptions::InvalidMessageId if not
    #   valid
    #
    def wf_message_id?(v)
      return true if v.is_a?(String) && v =~ /^\w+::\w+$/
      raise Wavefront::Exception::InvalidMessageId
    end

    # Ensure the given argument is a valid query granularity
    #
    # @param v [String] granularity
    # @return true if valid
    # @raise Wavefront::Exceptions::InvalidGranularity if not
    #   valid
    #
    def wf_granularity?(v)
      return true if %w[d h m s].include?(v.to_s)
      raise Wavefront::Exception::InvalidGranularity
    end

    # Ensure the given argument is a valid saved search ID.
    #
    # @param v [String] saved search ID
    # @return true if valid
    # @raise Wavefront::Exceptions::InvalidSavedSearchId if not valid
    #
    def wf_savedsearch_id?(v)
      return true if v.is_a?(String) && v =~ /^\w{8}$/
      raise Wavefront::Exception::InvalidSavedSearchId
    end

    # Ensure the given argument is a valid saved search entity type.
    #
    # @param v [String] entity type
    # @return true if valid
    # @raise Wavefront::Exceptions::InvalidSavedSearchEntity if not
    #   valid
    #
    def wf_savedsearch_entity?(v)
      return true if %w[DASHBOARD ALERT MAINTENANCE_WINDOW
                        NOTIFICANT EVENT SOURCE EXTERNAL_LINK AGENT
                        CLOUD_INTEGRATION].include?(v)
      raise Wavefront::Exception::InvalidSavedSearchEntity
    end

    # Ensure the given argument is a valid Wavefront source name
    #
    # @param v [String] the source name to validate
    # @return True if the source name is valid
    # @raise Wavefront::Exception::InvalidSourceId if the source name
    #   is not valid
    #
    def wf_source_id?(v)
      return true if v.is_a?(String) && v.match(/^[\w\.\-]+$/) && v.size < 1024

      raise Wavefront::Exception::InvalidSourceId
    end

    # Ensure the given argument is a valid user.
    #
    # @param v [String] user identifier
    # @return true if valid
    # @raise Wavefront::Exceptions::InvalidUserId if not valid
    #
    def wf_user_id?(v)
      return true if v.is_a?(String) &&
                     v =~ /\A([\w+\-].?)+@[a-z\d\-]+(\.[a-z]+)*\.[a-z]+\z/i
      raise Wavefront::Exception::InvalidUserId
    end

    # Ensure the given argument is a valid webhook ID.
    #
    # @param v [String] webhook ID
    # @return true if valid
    # @raise Wavefront::Exceptions::InvalidWebhook if not valid
    #
    def wf_webhook_id?(v)
      return true if v.is_a?(String) && v =~ /^[a-zA-Z0-9]{16}$/
      raise Wavefront::Exception::InvalidWebhookId
    end

    # Validate a point so it conforms to the standard described in
    # https://community.wavefront.com/docs/DOC-1031
    #
    # @param v [Hash] description of point
    # @return true if valie
    # @raise whichever exception is thrown first when validating
    #   each component of the point.
    #
    def wf_point?(v)
      wf_metric_name?(v[:path])
      wf_value?(v[:value])
      wf_epoch?(v[:ts]) if v[:ts]
      wf_source_id?(v[:source]) if v[:source]
      wf_point_tags?(v[:tags]) if v[:tags]
      true
    end

    # Ensure the given argument is a valid Wavefront
    # notificant ID.
    #
    # @param v [String] the notificant name to validate
    # @return True if the notificant name is valid
    # @raise Wavefront::Exception::InvalidNotificantId if the
    #   notificant ID is not valid
    #
    def wf_notificant_id?(v)
      return true if v.is_a?(String) && v =~ /^\w{16}$/
      raise Wavefront::Exception::InvalidNotificantId
    end

    # Ensure the given argument is a valid Wavefront
    # integration ID. These appear to be lower-case strings.
    #
    # @param v [String] the integration name to validate
    # @return True if the integration name is valid
    # @raise Wavefront::Exception::InvalidIntegrationId if the
    #   integration ID is not valid
    #
    def wf_integration_id?(v)
      return true if v.is_a?(String) && v =~ /^[a-z0-9]+$/
      raise Wavefront::Exception::InvalidIntegrationId
    end
  end
end
