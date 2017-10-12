require 'date'
require_relative './exception'

module Wavefront
  module Mixins
    # Return a time as an integer, however it might come in.
    #
    # @param t [Integer, String, Time] timestamp
    # @param ms [Boolean] whether to return epoch milliseconds.
    #   Passing in an integer timestamp returns itself, regardless
    #   of this value
    # @return [Integer] epoch time in seconds
    # @raise Wavefront::InvalidTimestamp
    #
    def parse_time(t, ms = false)
      #
      # Numbers, or things that look like numbers, pass straight
      # through. No validation, because maybe the user means one
      # second past the epoch, or the year 2525.
      #
      return t if t.is_a?(Numeric)

      if t.is_a?(String)
        return t.to_i if t.match(/^\d+$/)

        if t.start_with?('-') || t.start_with?('+')
          return relative_time(t, ms)
        end

        begin
          t = DateTime.parse("#{t} #{Time.now.getlocal.zone}")
        rescue
          raise Wavefront::Exception::InvalidTimestamp
        end
      end

      ms ? t.to_datetime.strftime('%Q').to_i : t.strftime('%s').to_i
    end

    # Return a timetamp described by the given string. That is,
    # '+5m' is five minutes in the future, and '-.1h' is half an
    # hour ago.
    #
    # @param t [String] relative time string. Must begin with + or
    #   -, followed by a number, finished with a lower-case time
    #   unit identifier. See #time_multiplier
    # @param ref [Time, DateTime] calculate time relative to this
    #   point. Primarily for easier testing. Defaults to "now".
    # @return [Integer] integer timestamp
    # @raise [InvalidRelativeTime] if t does not meet requirements
    #
    def relative_time(t, ms = false, ref = DateTime.now)
      ref = ms ? ref.to_date.strftime('%Q') : ref.to_time
      ref.to_i + parse_relative_time(t, ms)
    end

    def parse_relative_time(t, ms = false)
      unless t.start_with?('+') || t.start_with?('-')
        raise Wavefront::Exception::InvalidRelativeTime
      end

      m = ms ? 1000 : 1

      t = t[1..-1] if t.start_with?('+')
      match = t.match(/^(-?\d*\.?\d*)([smhdwy])$/)
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
      u = { s: 1, m: 60, h: 3600, d: 86400, w: 604800, y: 31536000 }

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
    self.map { |k, v| "#{k}=\"#{v}\"" }.join(' ')
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
    self.join('/').squeeze('/').sub(/\/$/, '').sub(/\/\?/, '?')
  end
end
