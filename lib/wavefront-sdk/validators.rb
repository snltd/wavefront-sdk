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
      return true if v.is_a?(String) && v.match(/^[\-\w \.,]*$/)

      raise Wavefront::Exception::InvalidString
    end

    # Ensure the given argument is a valid Wavefront source name
    #
    # @param v [String] the source name to validate
    # @return True if the source name is valid
    # @raise Wavefront::Exception::InvalidSource if the source name
    #   is not valid
    #
    def wf_source?(v)
      return true if v.is_a?(String) && v.match(/^[\w\.\-]+$/) && v.size < 1024
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

    # Ensure the given argument is a valid millisecond epoch timestamp
    #
    # @param v [Integer] the timestamp name to validate
    # @return True if the value is valid
    # @raise Wavefront::Exception::InvalidTimestamp
    #
    def wf_ms_ts?(v)
      return true if v.is_a?(Numeric)
      raise Wavefront::Exception::InvalidTimestamp
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
        unless (k.size + v.size < 254) && k.match(/^[\w\-\.]+$/)
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
  end
end
