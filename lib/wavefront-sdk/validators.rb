require_relative 'defs/constants'
require_relative 'core/exception'

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
    # Is the given string a UUID? These are used for various item
    # IDs.
    #
    # @param id [String]
    # @return [Bool]
    #
    def uuid?(str)
      str.is_a?(String) && str =~ /([a-f\d]{8}(-[a-f\d]{4}){3}-[a-f\d]{12})/
    end

    # Ensure the given argument is a valid external link template
    #
    # @return true if it is valid
    # @raise Wavefront::Exception::InvalidTemplate if not
    #
    def wf_link_template?(template)
      if template.is_a?(String) &&
         template.start_with?('http://', 'https://')
        return true
      end

      raise Wavefront::Exception::InvalidLinkTemplate
    end

    # Ensure the given argument is a valid Wavefront metric name, or
    # path.
    #
    # @param metric [String] the metric name to validate
    # @return True if the metric name is valid
    # @raise Wavefront::Exception::InvalidMetricName if metric name
    # is not valid.
    #
    def wf_metric_name?(metric)
      if metric.is_a?(String) && metric.size < 1024 &&
         (metric.match(/^#{DELTA}?[\w\-\.]+$/) ||
          metric.match(%r{^\"#{DELTA}?[\w\-\.\/,]+\"$}))
        return true
      end

      raise Wavefront::Exception::InvalidMetricName
    end

    # Ensure the given argument is a valid name, for instance for an
    # event. Names can contain, AFAIK, word characters.
    #
    # @param name [String] the name to validate
    # @return true if the name is valid
    # raise Wavefront::Exception::InvalidName if name is not valid
    #
    def wf_name?(name)
      return true if name.is_a?(String) && name.size < 1024 && name =~ /^\w+$/
      raise Wavefront::Exception::InvalidName
    end

    # Ensure the given argument is a valid string, for a tag name.
    #
    # @param str [String] the string name to validate
    # @return True if the string is valid
    # @raise Wavefront::Exception::InvalidString if string is not valid.
    #
    def wf_string?(str)
      #
      # Only allows PCRE "word" characters, spaces, full-stops and
      # commas in tags and descriptions. This might be too restrictive,
      # but if it is, this is the only place we need to change it.
      #
      if str.is_a?(String) && str.size < 1024 && str =~ /^[\-\w \.,]*$/
        return true
      end

      raise Wavefront::Exception::InvalidString
    end

    # Ensure the given argument is a valid timestamp
    #
    # @param timestamp [DateTime] the timestamp name to validate
    # @return True if the value is valid
    # @raise Wavefront::Exception::InvalidTimestamp
    #
    def wf_ts?(timestamp)
      return true if timestamp.is_a?(Time) || timestamp.is_a?(Date)
      raise Wavefront::Exception::InvalidTimestamp
    end

    # Ensure the given argument is a valid millisecond epoch
    # timestamp. We do no checking of the value, because who am I to
    # say that the user doesn't want to send a point relating to 1ms
    # after the epoch, or a thousand years in the future?
    #
    # @param timestamp [Integer] the timestamp name to validate
    # @return True if the value is valid
    # @raise Wavefront::Exception::InvalidTimestamp
    #
    def wf_ms_ts?(timestamp)
      return true if timestamp.is_a?(Numeric)
      raise Wavefront::Exception::InvalidTimestamp
    end

    # Ensure the given argument is a valid epoch timestamp. Again,
    # no range checking.
    #
    # @param timestamp [String, Integer]
    # @return True if the timestamp is valid
    # @raise Wavefront::Exception::InvalidMaintenanceWindow
    #
    def wf_epoch?(timestamp)
      return true if timestamp.is_a?(Numeric)
      raise Wavefront::Exception::InvalidTimestamp
    end

    # Ensure one, or an array, of tags are valid. These tags are
    # used as source tags, or tags for maintenance windows etc. They
    # can contain letters, numbers, -, _ and :, and must be less
    # than 256 characters long
    #
    # @param tags [String, Array] a tag or list of tags
    # @return True if all tags are valid
    # @raise Wavefront::Exception::InvalidTag
    #
    def wf_tag?(*tags)
      Array(*tags).each do |tag|
        unless tag.is_a?(String) && tag.size < 255 && tag =~ /^[\w:\-\.]+$/
          raise Wavefront::Exception::InvalidTag
        end
      end

      true
    end

    # Ensure the given argument is a valid Wavefront value. Can be
    # any form of Numeric, including standard notation.
    #
    # @param value [Numeric] the source name to validate
    # @return True if the value is valid
    # @raise Wavefront::Exception::InvalidValue if the value is not valid
    #
    def wf_value?(value)
      return true if value.is_a?(Numeric)
      raise Wavefront::Exception::InvalidMetricValue
    end

    # Ensure the given argument is a valid version number
    #
    # @param version [Integer] the version number to validate
    # @return True if the version is valid
    # @raise Wavefront::Exception::InvalidVersion if the alert ID is
    #   not valid
    #
    def wf_version?(version)
      version = version.to_i if version.is_a?(String) && version =~ /^\d+$/
      return true if version.is_a?(Integer) && version > 0
      raise Wavefront::Exception::InvalidVersion
    end

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

    # Validate a single point tag, probably on behalf of #wf_point_tags?
    # @param key [String] tag key
    # @param val [String] tag value
    # @raise Wavefront::Exception::InvalidTag if any tag is not valid
    # @return nil
    #
    def wf_point_tag?(key, val)
      if key && val && (key.size + val.size < 254) &&
         key =~ /^[\w\-\.:]+$/ && val !~ /\\$/
        return
      end

      raise Wavefront::Exception::InvalidTag
    end

    # Ensure the given argument is a valid Wavefront proxy ID
    #
    # @param id [String] the proxy ID to validate
    # @return True if the proxy ID is valid
    # @raise Wavefront::Exception::InvalidProxyId if the proxy ID
    #   is not valid
    #
    def wf_proxy_id?(id)
      return true if uuid?(id)
      raise Wavefront::Exception::InvalidProxyId
    end

    # Ensure the given argument is a valid Wavefront alert ID.
    # Alerts are identified by the epoch-nanosecond at which they
    # were created.
    #
    # @param id [String] the alert ID to validate
    # @return True if the alert ID is valid
    # @raise Wavefront::Exception::InvalidAlertId if the alert ID is
    #   not valid
    #
    def wf_alert_id?(id)
      id = id.to_s if id.is_a?(Numeric)
      return true if id.is_a?(String) && id.match(/^\d{13}$/)
      raise Wavefront::Exception::InvalidAlertId
    end

    # Ensure the given argument is a valid Wavefront cloud
    # integration ID
    #
    # @param id [String] the integration name to validate
    # @return True if the integration name is valid
    # @raise Wavefront::Exception::InvalidCloudIntegrationId if the
    #   integration ID is not valid
    #
    def wf_cloudintegration_id?(id)
      return true if uuid?(id)
      raise Wavefront::Exception::InvalidCloudIntegrationId
    end

    # There doesn't seem to be a public statement on what's allowed
    # in a dashboard name. For now I'm going to assume up to 255 word
    # characters.
    #
    # @param id [String] the dashboard ID to validate
    # @return true if the dashboard ID is valid
    # @raise Wavefront::Exception::InvalidDashboardID if the
    #   dashboard ID is not valid
    #
    def wf_dashboard_id?(id)
      return true if id.is_a?(String) && id.size < 256 && id.match(/^[\w\-]+$/)
      raise Wavefront::Exception::InvalidDashboardId
    end

    # Ensure the given argument is a valid derived metric ID.  IDs
    # are the millisecond epoch timestamp at which the derived
    # metric was created.
    #
    # @param id [String, Integer]
    # @return True if the ID is valid
    # @raise Wavefront::Exception::InvalidDerivedMetricId
    #
    def wf_derivedmetric_id?(id)
      id = id.to_s if id.is_a?(Numeric)
      return true if id.is_a?(String) && id =~ /^\d{13}$/

      raise Wavefront::Exception::InvalidDerivedMetricId
    end

    # Ensure the given argument is a valid event ID. Event IDs are
    # an epoch-millisecond timestamp followed by a : followed by the
    # name of the event.
    #
    # @param id [String] the event ID to validate
    # @return true if the event ID is valid
    # @raise Wavefront::Exception::InvalidEventID if the
    #   event ID is not valid
    #
    def wf_event_id?(id)
      return true if id.is_a?(String) && id =~ /^\d{13}:.+/
      raise Wavefront::Exception::InvalidEventId
    end

    # Ensure the given argument is a valid external Link ID
    #
    # @param id [String] the external link ID to validate
    # @return True if the link ID is valid
    # @raise Wavefront::Exception::InvalidExternalLinkId if the
    #   link ID is not valid
    #
    def wf_link_id?(id)
      return true if id.is_a?(String) && id =~ /^\w{16}$/
      raise Wavefront::Exception::InvalidExternalLinkId
    end

    # Ensure the given argument is a valid maintenance window ID.
    # IDs are the millisecond epoch timestamp at which the window
    # was created.
    #
    # @param id [String, Integer]
    # @return True if the ID is valid
    # @raise Wavefront::Exception::InvalidMaintenanceWindowId
    #
    def wf_maintenance_window_id?(id)
      id = id.to_s if id.is_a?(Numeric)
      return true if id.is_a?(String) && id =~ /^\d{13}$/

      raise Wavefront::Exception::InvalidMaintenanceWindowId
    end

    # Ensure the given argument is a valid alert severity
    #
    # @param severity [String] severity
    # @return true if valid
    # @raise Wavefront::Exceptions::InvalidAlertSeverity if not valid
    #
    def wf_alert_severity?(severity)
      return true if %w[INFO SMOKE WARN SEVERE].include?(severity)
      raise Wavefront::Exception::InvalidAlertSeverity
    end

    # Ensure the given argument is a valid message ID
    #
    # @param id [String] message ID
    # @return true if valid
    # @raise Wavefront::Exceptions::InvalidMessageId if not valid
    #
    def wf_message_id?(id)
      return true if id.is_a?(String) && id =~ /^\w+::\w+$/
      raise Wavefront::Exception::InvalidMessageId
    end

    # Ensure the given argument is a valid query granularity
    #
    # @param granularity [String] granularity
    # @return true if valid
    # @raise Wavefront::Exceptions::InvalidGranularity if not
    #   valid
    #
    def wf_granularity?(granularity)
      return true if %w[d h m s].include?(granularity.to_s)
      raise Wavefront::Exception::InvalidGranularity
    end

    # Ensure the given argument is a valid saved search ID.
    #
    # @param id [String] saved search ID
    # @return true if valid
    # @raise Wavefront::Exceptions::InvalidSavedSearchId if not valid
    #
    def wf_savedsearch_id?(id)
      return true if id.is_a?(String) && id =~ /^\w{8}$/
      raise Wavefront::Exception::InvalidSavedSearchId
    end

    # Ensure the given argument is a valid saved search entity type.
    #
    # @param id [String] entity type
    # @return true if valid
    # @raise Wavefront::Exceptions::InvalidSavedSearchEntity if not
    #   valid
    #
    def wf_savedsearch_entity?(id)
      return true if %w[DASHBOARD ALERT MAINTENANCE_WINDOW
                        NOTIFICANT EVENT SOURCE EXTERNAL_LINK AGENT
                        CLOUD_INTEGRATION].include?(id)
      raise Wavefront::Exception::InvalidSavedSearchEntity
    end

    # Ensure the given argument is a valid Wavefront source name
    #
    # @param source [String] the source name to validate
    # @return True if the source name is valid
    # @raise Wavefront::Exception::InvalidSourceId if the source name
    #   is not valid
    #
    def wf_source_id?(source)
      if source.is_a?(String) && source.match(/^[\w\.\-]+$/) &&
         source.size < 1024
        return true
      end

      raise Wavefront::Exception::InvalidSourceId
    end

    # Ensure the given argument is a valid user.
    #
    # @param user [String] user identifier
    # @return true if valid
    # @raise Wavefront::Exceptions::InvalidUserId if not valid
    #
    def wf_user_id?(user)
      if user.is_a?(String) &&
         user =~ /\A([\w+\-].?)+@[a-z\d\-]+(\.[a-z]+)*\.[a-z]+\z/i
        return true
      end

      raise Wavefront::Exception::InvalidUserId
    end

    # Ensure the given argument is a valid user group.
    #
    # @param gid [String] user group identiier
    # @return true if valid
    # @raise Wavefront::Exceptions::InvalidUserGroupId if not valid
    #
    def wf_usergroup_id?(gid)
      return true if uuid?(gid)
      raise Wavefront::Exception::InvalidUserGroupId
    end

    # Ensure the given argument is a valid webhook ID.
    #
    # @param id [String] webhook ID
    # @return true if valid
    # @raise Wavefront::Exceptions::InvalidWebhook if not valid
    #
    def wf_webhook_id?(id)
      return true if id.is_a?(String) && id =~ /^[a-zA-Z0-9]{16}$/
      raise Wavefront::Exception::InvalidWebhookId
    end

    # Validate a point so it conforms to the standard described in
    # https://community.wavefront.com/docs/DOC-1031
    #
    # @param point [Hash] description of point
    # @return true if valid
    # @raise whichever exception is thrown first when validating
    #   each component of the point.
    #
    def wf_point?(point)
      wf_metric_name?(point[:path])
      wf_value?(point[:value])
      wf_epoch?(point[:ts]) if point[:ts]
      wf_source_id?(point[:source]) if point[:source]
      wf_point_tags?(point[:tags]) if point[:tags]
      true
    end

    # Validate a distribution description
    # @param dist [Hash] description of distribution
    # @return true if valid
    # @raise whichever exception is thrown first when validating
    #   each component of the distribution.
    #
    def wf_distribution?(dist)
      wf_metric_name?(dist[:path])
      wf_distribution_values?(dist[:value])
      wf_epoch?(dist[:ts]) if dist[:ts]
      wf_source_id?(dist[:source]) if dist[:source]
      wf_point_tags?(dist[:tags]) if dist[:tags]
      true
    end

    # Validate an array of distribution values
    # @param vals [Array[Array]] [count, value]
    # @return true if valid
    # @raise whichever exception is thrown first when validating
    #   each component of the distribution.
    #
    def wf_distribution_values?(vals)
      vals.each do |times, val|
        wf_distribution_count?(times)
        wf_value?(val)
      end
      true
    end

    # Ensure the given argument is a valid Wavefront notificant ID.
    #
    # @param id [String] the notificant ID to validate
    # @return True if the notificant ID is valid
    # @raise Wavefront::Exception::InvalidNotificantId if the
    #   notificant ID is not valid
    #
    def wf_notificant_id?(id)
      return true if id.is_a?(String) && id =~ /^\w{16}$/
      raise Wavefront::Exception::InvalidNotificantId
    end

    # Ensure the given argument is a valid Wavefront
    # integration ID. These appear to be lower-case strings.
    #
    # @param id [String] the integration ID to validate
    # @return True if the integration name is valid
    # @raise Wavefront::Exception::InvalidIntegrationId if the
    #   integration ID is not valid
    #
    def wf_integration_id?(id)
      return true if id.is_a?(String) && id =~ /^[a-z0-9]+$/
      raise Wavefront::Exception::InvalidIntegrationId
    end

    # Ensure the given argument is a valid distribution interval.
    # @param interval [Symbol]
    # @raise Wavefront::Exception::InvalidDistributionInterval if the
    #   interval is not valid
    #
    def wf_distribution_interval?(interval)
      return true if %i[m h d].include?(interval)
      raise Wavefront::Exception::InvalidDistributionInterval
    end

    # Ensure the given argument is a valid distribution count.
    # @param count [Numeric]
    # @raise Wavefront::Exception::InvalidDistributionCount if the
    #   count is not valid
    #
    def wf_distribution_count?(count)
      return true if count.is_a?(Integer) && count > 0
      raise Wavefront::Exception::InvalidDistributionCount
    end
  end
  # rubocop:enable Metrics/ModuleLength
end
