# frozen_string_literal: true

require 'time'

module Wavefront
  #
  # Parse various times into integers. This class is not for direct
  # consumption: it's used by the mixins parse_time method, which
  # does all the type sanity stuff.
  #
  class ParseTime
    attr_reader :t, :ms

    # param t [Numeric] a timestamp
    # param ms [Bool] whether the timestamp is in milliseconds
    #
    def initialize(time, in_ms = false)
      @t = time
      @ms = in_ms
    end

    # @return [Fixnum] timestamp
    #
    def parse_time_fixnum
      t
    end

    # @return [Integer] timestamp
    #
    def parse_time_integer
      t
    end

    # @return [Fixnum] timestamp
    #
    def parse_time_string
      return t.to_i if t =~ /^\d+$/

      @t = Time.parse("#{t} #{Time.now.getlocal.zone}")
      parse_time_time
    end

    # @return [Integer] timestamp
    #
    def parse_time_time
      if ms
        t.to_datetime.strftime('%Q').to_i
      else
        t.strftime('%s').to_i
      end
    end

    def parse_time_datetime
      parse_time_time
    end

    def parse!
      method = ('parse_time_' + t.class.name.downcase).to_sym
      send(method)
    rescue StandardError
      raise Wavefront::Exception::InvalidTimestamp
    end
  end
end
