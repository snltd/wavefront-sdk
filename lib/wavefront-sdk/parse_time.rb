module Wavefront
  # Parse various times into integers. This class is not for direct
  # consumption: it's used by the mixins parse_time method, which
  # does all the type sanity stuff.
  #
  class ParseTime
    attr_reader :t, :ms

    # param t [Numeric] a timestamp
    # param ms [Bool] whether the timestamp is in milliseconds
    #
    def initialize(t, ms = false)
      @t = t
      @ms = ms
    end

    # @return [Fixnum] timestamp
    #
    def parse_time_Fixnum
      t
    end

    # @return [Integer] timestamp
    #
    def parse_time_Integer
      t
    end

    # @return [Fixnum] timestamp
    #
    def parse_time_String
      return t.to_i if t =~ /^\d+$/
      @t = DateTime.parse("#{t} #{Time.now.getlocal.zone}")
      parse_time_Time
    end

    # @return [Integer] timestamp
    #
    def parse_time_Time
      if ms
        t.to_datetime.strftime('%Q').to_i
      else
        t.strftime('%s').to_i
      end
    end

    def parse_time_DateTime
      parse_time_Time
    end

    def parse!
      method = ('parse_time_' + t.class.name).to_sym
      send(method)
    rescue
      raise Wavefront::Exception::InvalidTimestamp
    end
  end
end
