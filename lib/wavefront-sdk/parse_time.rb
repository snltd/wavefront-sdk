module Wavefront
  # Parse various times into integers
  #
  class ParseTime
    attr_reader :t, :ms

    def initialize(t, ms)
      @t = t
      @ms = ms
    end

    def parse_time_Fixnum
      t
    end

    def parse_time_String
      return t.to_i if t =~ /^\d+$/
      @t = DateTime.parse("#{t} #{Time.now.getlocal.zone}")
      parse_time_Time
    end

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
