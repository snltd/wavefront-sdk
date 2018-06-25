require 'date'
require_relative 'exception'
require_relative 'parse_time'

module Wavefront
  #
  # Methods which help out in the SDK, but may also be useful when
  # coding against the SDK.
  #
  module Mixins
    # Return a time as an integer, however it might come in.
    #
    # @param time [Integer, String, Time] timestamp
    # @param in_ms [Boolean] whether to return epoch milliseconds.
    #   Passing in an integer timestamp returns itself, regardless
    #   of this value
    # @return [Integer] epoch time in seconds
    # @raise Wavefront::InvalidTimestamp
    #
    def parse_time(time, in_ms = false)
      return relative_time(time, in_ms) if time =~ /^[\-+]/
      ParseTime.new(time, in_ms).parse!
    end

    # Return a timestamp described by the given string. That is,
    # '+5m' is five minutes in the future, and '-.1h' is half an
    # hour ago.
    #
    # @param time [String] relative time string. Must begin with + or
    #   -, followed by a number, finished with a lower-case time
    #   unit identifier. See #time_multiplier
    # @param in_ms [Boolean] whether to return epoch milliseconds.
    #   Passing in an integer timestamp returns itself, regardless
    #   of this value
    # @param ref [Time, DateTime] calculate time relative to this
    #   point. Primarily for easier testing. Defaults to "now".
    # @return [Integer] integer timestamp
    # @raise [InvalidRelativeTime] if t does not meet requirements
    #
    def relative_time(time, in_ms = false, ref = Time.now)
      ref = in_ms ? ref.to_datetime.strftime('%Q') : ref.to_time
      ref.to_i + parse_relative_time(time, in_ms)
    end

    def parse_relative_time(time, in_ms = false)
      unless time.start_with?('+', '-')
        raise Wavefront::Exception::InvalidRelativeTime
      end

      m = in_ms ? 1000 : 1

      time = time[1..-1] if time.start_with?('+')
      match = time.match(/^(-?\d*\.?\d*)([smhdwy])$/)
      (match[1].to_f * time_multiplier(match[2]) * m).to_i
    rescue NoMethodError
      raise Wavefront::Exception::InvalidRelativeTime
    end

    # naively return the number of seconds from the given
    # multiplier. This makes absolutely no attempt to compensate for
    # any kind of daylight savings or calendar adjustment. A day is
    # always going to 60 seconds x 60 minutes x 24 hours, and a
    # year will always have 365 days.
    #
    # @param suffix [Symbol, String]
    # @return [Integer] the number of seconds in one unit of the
    #   given suffix
    # @raise InvalidTimeUnit if the suffix is unknown
    #
    def time_multiplier(suffix)
      u = { s: 1, m: 60, h: 3600, d: 86_400, w: 604_800, y: 31_536_000 }

      return u[suffix.to_sym] if u.key?(suffix.to_sym)
      raise Wavefront::Exception::InvalidTimeUnit
    end
  end
end

# Extensions to stdlib Hash
#
class Hash
  # Convert a tag hash into a string. The quoting is recommended in
  # the WF wire-format guide. No validation is performed here.
  #
  def to_wf_tag
    map { |k, v| "#{k}=\"#{v}\"" }.join(' ')
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
    join('/').squeeze('/').sub(%r{\/$}, '').sub(%r{\/\?}, '?')
  end
end
