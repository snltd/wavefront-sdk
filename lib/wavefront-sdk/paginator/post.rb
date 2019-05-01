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
      # super#setpagination requires that the args are an array, and
      # that one of the args is a hash containing limit and offset
      # keys.
      #
      def set_pagination(offset, limit, args)
        super(offset, limit, body_as(Hash, args))
        body_as(String, args)
      end

      # super#limit_and_offset requires a hash containing the limit
      # and offset values. In a POST that's in the body of the
      # request, which at this point has been turned into a JSON
      # string. We have to temporarily turn it back into an object
      # and pass it up to the superclass.
      #
      # The body is the second argument. We'll allow for it already
      # being an object, just in case.
      #
      def limit_and_offset(args)
        super(body_as(Hash, args))
      end

      # Faraday needs the body of the POST to be described as a JSON
      # string, but our methods which modify the body for recursive
      # calls need it as a hash. This method takes an array of args
      # and ensures the body element is either a string or an
      # object. If the body cannot be turned into JSON, which some
      # bodies can't, return an empty array.
      #
      # @param desired [Class] String or Hash, what you want the
      #   class of the body element to be
      # @param args [Array] the arguments to the Faraday call method
      # @params index [Integer] the index of the body element.
      #   Always 1, AFAIK.
      # @return [Array] of args
      #
      def body_as(desired, args, index = 1)
        body = args[index]

        return args if body.class == desired

        args[index] = body_as_json(body)
        args
      rescue JSON::ParserError
        []
      end

      def body_as_json(body)
        return body.to_json unless body.is_a?(String)

        JSON.parse(body, symbolize_names: true)
      end
    end
  end
end
