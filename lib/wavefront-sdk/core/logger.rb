# frozen_string_literal: true

module Wavefront
  #
  # Log to a user-supplied Ruby logger, or to standard output.
  #
  class Logger
    attr_reader :logger, :verbose, :debug

    # @param opts [Hash] options hash from a child of Wavefront::Base
    #
    def initialize(opts = {})
      @logger  = opts[:logger] || nil
      @verbose = opts[:verbose] || nil
      @debug   = opts[:debug] || nil
    end

    # Send a message to a Ruby logger object if the user supplied
    # one, or print to standard out if not.
    #
    # @param msg [String] the string to print
    # @param level [Symbol] the level of the message.
    #   :verbose messages equate to a standard INFO log level and
    #   :debug to DEBUG.
    #
    def log(msg, level = :info)
      if logger
        logger.send(level, msg)
      else
        print_message(level, msg)
      end
    end

    def print_message(level, msg)
      method = format('print_%<level>s_message', level: level).to_sym
      msg = format_message(level, msg)

      if respond_to?(:method)
        send(method, msg)
      else
        print_warn_message(format('undefined message level:%<level>s',
                                  level: level))
        print_warn_message(msg)
      end
    end

    def format_message(level, msg)
      format('SDK %<level>s: %<msg>s', level: level.to_s.upcase, msg: msg)
    end

    def print_debug_message(msg)
      puts msg if debug
    end

    def print_info_message(msg)
      puts msg if debug || verbose
    end

    def print_warn_message(msg)
      warn msg
    end

    def print_error_message(msg)
      warn msg
    end
  end
end
