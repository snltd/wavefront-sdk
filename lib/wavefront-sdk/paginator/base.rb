require_relative '../defs/constants'

module Wavefront
  module Paginator
    #
    # Automatically handle pagination. This is an abstract class
    # made concrete by an extension for each HTTP request type.
    #
    # This class and its children do slightly unpleasant things with
    # the HTTP request passed to us by the user, extracting and
    # changing values in the URI, query string, or POST/PUT body.
    # The POST class is particularly onerous.
    #
    # Automatic pagination works by letting the user override the
    # limit and offset values in API calls. Setting the limit to
    # :all iteratively calls the Wavefront API, returning all
    # requested objects an a standard Wavefront::Response wrapper;
    # setting limit to :lazy returns a lazy Enumerable. The number
    # of objects fetched in each API call, whether eager or lazy
    # defaults to PAGE_SIZE, but the user can override that value by
    # using the offset argument in conjunction with limit = :lazy |
    # :all.
    #
    class Base
      attr_reader :api_caller, :conn, :method, :args, :page_size,
                  :initial_limit

      # @param api_caller [Wavefront::ApiCaller] the class which
      #   creates an instance of this one. We need to access its
      #   #response method.
      # @param conn [Faraday::Connection]
      # @param method [Symbol] HTTP request method
      # @param *args arguments to pass to Faraday's #get method
      #
      def initialize(api_caller, conn, method, *args)
        @api_caller  = api_caller
        @conn        = conn
        @method      = method
        @args        = args
        setup_vars
      end

      def setup_vars
        @initial_limit = limit_and_offset(args)[:limit]
        @page_size = user_page_size(args) unless initial_limit.is_a?(Integer)
      end

      # An API call may or may not have a limit and/or offset value.
      # They could (I think) be anywhere. Safely find and return
      # them. If multiple elements of @args have :limit or :offset
      # keys, the last value wins.
      #
      # @param args [Array] arguments to be passed to a Faraday
      #   connection object
      # @return [Hash] with keys :offset and :limit. Either's value
      #   can be nil
      #
      def limit_and_offset(args)
        ret = { offset: nil, limit: nil }

        args.select { |a| a.is_a?(Hash) }.each_with_object(ret) do |arg, a|
          a[:limit] = arg[:limit] if arg.key?(:limit)
          a[:offset] = arg[:offset] if arg.key?(:offset)
        end
      end

      # How many objects to get on each iteration? The user can pass
      # it in as an alternative to the offset argument, If it's not a
      # positive integer, default to 999
      #
      def user_page_size(args)
        arg_val = limit_and_offset(args)[:offset].to_i
        return arg_val if arg_val&.positive?
        PAGE_SIZE
      end

      # @param offset [Integer] where to start fetching from
      # @param page_size [Integer] how many objects to fetch
      # @param args [Array] arguments to pass to Faraday.get
      #
      def set_pagination(offset, page_size, args)
        args.map do |arg|
          if arg.is_a?(Hash)
            arg.tap do |a|
              a[:limit] = page_size if a.key?(:limit)
              a[:offset] = offset if a.key?(:offset)
            end
          end
          arg
        end
      end

      # 'get' eagerly. Re-run the get operation, merging together
      # returned items until we have them all.
      # @return [Wavefront::Response]
      #
      # rubocop:disable Metrics/MethodLength
      # rubocop:disable Metrics/AbcSize
      def make_recursive_call
        offset = 0
        p_args = set_pagination(offset, page_size, args)
        ret = api_caller.respond(conn.public_send(method, *p_args))

        return ret unless ret.more_items?

        loop do
          offset += page_size
          p_args = set_pagination(offset, page_size, p_args)
          api_caller.verbosity(conn, method, *p_args)
          resp = api_caller.respond(conn.public_send(method, *p_args))
          raise StopIteration unless resp.ok?
          ret.response.items += resp.response.items
          raise StopIteration unless resp.more_items?
        end

        ret
      end

      # Return all objects using a lazy enumerator.
      # @return [Enumerable] with each item being
      # @raise [Wavefront::Exception::EnumerableError] if an API error
      #   is encountered at any point. The exception message is a
      #   Wavefront::Type::Status object, which will include the HTTP
      #   status code and any error string passed back by the API.
      #
      def make_lazy_call
        offset = 0
        p_args = set_pagination(offset, page_size, args)

        Enumerator.new do |y|
          loop do
            offset += page_size
            api_caller.verbosity(conn, method, *p_args)
            resp = api_caller.respond(conn.public_send(method, *p_args))
            unless resp.ok?
              raise(Wavefront::Exception::EnumerableError, resp.status)
            end
            p_args = set_pagination(offset, page_size, p_args)
            resp.response.items.map { |i| y.<< i }
            raise StopIteration unless resp.more_items?
          end
        end.lazy
      end
      # rubocop:enable Metrics/AbcSize
      # rubocop:enable Metrics/MethodLength
    end
  end
end
