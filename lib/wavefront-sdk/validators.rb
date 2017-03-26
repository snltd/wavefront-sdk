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
    def wf_metric_name?(v)
      if v.is_a?(String) && v.size < 1024 &&
         (v.match(/^[\w\-\.]+$/) || v.match(%r{^\"[\w\-\.\/,]+\"$}))
        return true
      end

      raise Wavefront::Exception::InvalidMetricName
    end

    def wf_string?(v)
      #
      # Only allows PCRE "word" characters, spaces, full-stops and
      # commas in tags and descriptions. This might be too restrictive,
      # but if it is, this is the only place we need to change it.
      #
      return true if v.is_a?(String) && v.match(/^[\-\w \.,]*$/)

      raise Wavefront::Exception::InvalidString
    end

    def wf_source?(v)
      return true if v.is_a?(String) && v.match(/^[\w\.\-]+$/) && v.size < 1024
      raise Wavefront::Exception::InvalidSource
    end

    def wf_value?(v)
      return true if v.is_a?(Numeric)
      raise Wavefront::Exception::InvalidMetricValue
    end

    def wf_ts?(v)
      return true if v.is_a?(Time) || v.is_a?(Date)
      raise Wavefront::Exception::InvalidTimestamp
    end

    def wf_point_tags?(tags)
      #
      # Operates on a hash of key-value point tags. These are
      # different from source tags.
      #
      raise Wavefront::Exception::InvalidTag unless tags.is_a?(Hash)

      tags.each do |k, v|
        unless (k.size + v.size < 254) && k.match(/^[\w\-\.]+$/)
          raise Wavefront::Exception::InvalidTag
        end
      end
      true
    end

    def wf_agent?(v)
      if v.is_a?(String) && v.match(
        /^[a-f0-9]{8}-[a-f0-9]{4}-[a-f0-9]{4}-[a-f0-9]{4}-[a-f0-9]{12}$/
      )
        return true
      end

      raise Wavefront::Exception::InvalidAgent
    end

    def wf_alert?(v)
      #
      # Alerts are identified by the epoch-nanosecond at which they
      # were created.
      #
      v = v.to_s if v.is_a?(Numeric)

      return true if v.is_a?(String) && v.match(/^\d{13}$/)
      raise Wavefront::Exception::InvalidAlert
    end
  end
end
