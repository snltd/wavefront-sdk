require_relative './exception'

module Wavefront
  module Mixins
    # Return a time as an integer, however it might come in.
    #
    # @param t [Integer, String, Time] timestamp
    # @param ms [Boolean] whether to return epoch milliseconds
    # @return [Integer] epoch time in seconds
    # @raise Wavefront::InvalidTimestamp
    #
    def parse_time(t, ms = false)
      #
      # Numbers, or things that look like numbers, pass straight
      # through. No validation, because maybe the user means one
      # second past the epoch, or the year 2525.
      #
      return t if t.is_a?(Integer)

      if t.is_a?(String)
        return t.to_i if t.match(/^\d+$/)
        begin
          t = DateTime.parse("#{t} #{Time.now.getlocal.zone}")
        rescue
          raise Wavefront::Exception::InvalidTimestamp
        end
      end

      ms ? t.to_datetime.strftime('%Q').to_i : t.strftime('%s').to_i
    end
  end
end

# Extensions to the Hash class
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
