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
  module Validators

    # Ensure a hash of options matches requirements.
    #
    # @param hash [Hash] the hash to validate
    # @param desc [Hash] a description of 'hash'. Keys are the
    #   keys 'hash' may contain, values are an array where the first
    #   element is the method used to validate the 'hash' value, and
    #   the optional second element says whether the key is
    #   :required or If you do not wish the field to be validated,
    #   set the validator to nil.
    # @return True if everything checks out
    # @raise ArgumentError if 'hash' is not a Hash; 'unknown key k'
    #   if any key in 'hash' is not described in 'desc';
    #
    def validate_hash(hash, desc)
      raise ArgumentError unless hash.is_a?(Hash) && desc.is_a?(Hash)

      desc.select { |k, v| v.include?(:required) }.each do |k, _v|
        raise "missing key: #{k}" unless hash.key?(k)
      end

      hash.each do |k, v|
        raise "unknown key: #{k}" unless desc.key?(k)
        validator = desc[k].first
        next if validator.nil?
        public_send(validator, v)
      end
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
         (v.match(/^[\w\-\.]+$/) || v.match(%r{^\"[\w\-\.\/,]+\"$}))
        return true
      end

      raise Wavefront::Exception::InvalidMetricName
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

    # Ensure the given argument is a valid Wavefront source name
    #
    # @param v [String] the source name to validate
    # @return True if the source name is valid
    # @raise Wavefront::Exception::InvalidSource if the source name
    #   is not valid
    #
    def wf_source?(v)
      if v.is_a?(String) && v.match(/^[\w\.\-]+$/) && v.size < 1024
        return true
      end

      raise Wavefront::Exception::InvalidSource
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

      tags.each do |k, v|
        unless (k.size + v.size < 254) && k.match(/^[\w\-\.:]+$/)
          raise Wavefront::Exception::InvalidTag
        end
      end
      true
    end

    # Ensure the given argument is a valid Wavefront agent name
    #
    # @param v [String] the agent name to validate
    # @return True if the agent name is valid
    # @raise Wavefront::Exception::InvalidAgent if the agent name
    #   is not valid
    #
    def wf_agent?(v)
      if v.is_a?(String) && v.match(
        /^[a-f0-9]{8}-[a-f0-9]{4}-[a-f0-9]{4}-[a-f0-9]{4}-[a-f0-9]{12}$/
      )
        return true
      end

      raise Wavefront::Exception::InvalidAgent
    end

    # Ensure the given argument is a valid Wavefront cloud
    # integration name
    #
    # @param v [String] the integration name to validate
    # @return True if the integration name is valid
    # @raise Wavefront::Exception::InvalidCloudIntegration if the
    #   agent name is not valid
    #
    def wf_cloudintegration?(v)
      if v.is_a?(String) && v.match(
        /^[a-f0-9]{8}-[a-f0-9]{4}-[a-f0-9]{4}-[a-f0-9]{4}-[a-f0-9]{12}$/
      )
        return true
      end

      raise Wavefront::Exception::InvalidCloudIntegration
    end

    # Ensure the given argument is a valid Wavefront alert ID.
    # Alerts are identified by the epoch-nanosecond at which they
    # were created.
    #
    # @param v [String] the alert ID to validate
    # @return True if the alert ID is valid
    # @raise Wavefront::Exception::InvalidAlert if the alert ID is
    #   not valid
    #
    def wf_alert?(v)
      v = v.to_s if v.is_a?(Numeric)
      return true if v.is_a?(String) && v.match(/^\d{13}$/)
      raise Wavefront::Exception::InvalidAlert
    end

    # There doesn't seem to be a public statement on what's allowed
    # in a dashboard name. For now I'm going to assume up to 255 word
    # characters.
    #
    def wf_dashboard?(v)
      return true if v.is_a?(String) && v.size < 256 && v.match(/^\w+$/)
      raise Wavefront::Exception::InvalidDashboard
    end

    # Ensure the given argument is a valid event ID. Event IDs are
    # an epoch-millisecond timestamp followed by a : followed by the
    # name of the event.
    #
    def wf_event?(v)
      return true if v.is_a?(String) && v =~ /^\d{13}:\w+$/
      raise Wavefront::Exception::InvalidEvent
    end

    # Ensure the given argument is a valid version number
    #
    # @return True if the version is valid
    # @raise Wavefront::Exception::InvalidVersion if the alert ID is
    #   not valid
    #
    def wf_version?(v)
      return true if v.is_a?(Integer) && v > 0
      raise Wavefront::Exception::InvalidVersion
    end

    # Ensure the given argument is a valid external Link ID
    #
    # @return True if the link ID is valid
    # @raise Wavefront::Exception::InvalidVersion if the alert ID is
    #   not valid
    #
    def wf_link_id?(v)
      return true if v.is_a?(String) && v =~ /^\w{16}$/
      raise Wavefront::Exception::InvalidExternalLink
    end

    # Ensure the given argument is a valid external link template
    #
    # @return true if it is valid
    # @raise Wavefront::Exception::InvalidTemplate if not
    #
    def wf_link_template?(v)
      if v.is_a?(String) && (v.start_with?('http://') ||
                             v.start_with?('https://'))
        return true
      end

      raise Wavefront::Exception::InvalidLinkTemplate
    end

    # Ensure the given argument is a valid maintenance window ID.
    # IDs are the millisecond epoch timestamp at which the window
    # was created.
    #
    # @param v [String, Integer]
    # @return True if the ID is valid
    # @raise Wavefront::Exception::InvalidMaintenanceWindow
    #
    def wf_maintenance_window?(v)
      v = v.to_s if v.is_a?(Numeric)
      return true if v.is_a?(String) && v =~ /^\d{13}$/

      raise Wavefront::Exception::InvalidMaintenanceWindow
    end

    # Ensure the given argument is a valid alert severity
    #
    # @param v [String] severity
    # @return true if valid
    # @raise Wavefront::Exceptions::InvalidAlertSeverity if not
    # valid
    #
    def wf_alert_severity?(v)
      return true if %w(info smoke warn severe).include?(v)
      raise Wavefront::Exception::InvalidAlertSeverity
    end
  end
end
