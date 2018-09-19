require 'json'
require_relative 'base'

module Wavefront
  module Paginator
    #
    # We need to monkey-patch the Base class to pre-process data for
    # a couple of methods.
    #
    class Post < Base
      #
      # The limit and offset are in the second arg
      #
      def set_pagination(offset, limit, args)
        body = JSON.parse(args[1], symbolize_names: true)
        new_args = args.dup
        new_args[1] = body
        munged_args = super(offset, limit, new_args)
        stringed_body = munged_args[1].to_json
        new_args[1] = stringed_body
        new_args
      end

      # The body is the second argument, and it may have a limit and
      # offset inside.
      #
      def limit_and_offset(args)
        super([JSON.parse(args[1], symbolize_names: true)])
      end
    end
  end
end
