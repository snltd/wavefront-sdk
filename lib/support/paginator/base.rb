module Wavefront
  module Paginator
    #
    # Automatically handle pagination. This is an abstract class
    # made concrete by an extension for each HTTP transport type.
    #
    class Base
      attr_reader :calling_class, :conn, :method, :args, :page_size

      # @param conn [Faraday::Connection]
      # @param *args arguments to pass to Faraday's #get method
      #
      def initialize(calling_class, conn, method, *args)
        @calling_class = calling_class
        @conn      = conn
        @method    = method
        @args      = args
        @page_size = user_page_size
      end

      # How many objects to get on each iteration? The user can pass
      # it in as an alternative to the offset argument, If it's not a
      # positive integer, default to 999
      #
      def user_page_size
        arg_val = limit_and_offset(args)[:offset]
        return arg_val if arg_val > 0
        999
      end

      # @param limit [Integer] desired value of limit
      # @param offset [Integer] desired value of offset
      # @param args [Array] arguments to pass to Faraday.get
      #
      def set_pagination(offset, page_size, args)
        args.map do |arg|
          arg.tap do |a|
            next unless a.is_a?(Hash) && a.key?(:limit) && a.key?(:offset)
            a[:limit] = page_size
            a[:offset] = offset
          end
        end
      end

      # An API call may or may not have a limit and/or offset value.
      # They could (I think) be anywhere. Safely find and return them
      #
      # @param args [Array] arguments to be passed to a Faraday
      #   connection object
      # @return [Array] [offset, limit] either can be nil
      #
      def limit_and_offset(args)
        ret = { offset: page_size, limit: nil }

        args.select { |a| a.is_a?(Hash) }.each do |arg|
          ret[:limit] = arg.fetch(:limit, nil)
          ret[:offset] = arg.fetch(:offset, page_size)
        end

        ret
      end

      # 'get' eagerly. Re-run the get operation, merging together
      # returned items until we have them all.
      # @return [Wavefront::Response]
      #
      # rubocop:disable Metrics/AbcSize
      def make_recursive_call
        offset = 0
        p_args = set_pagination(offset, page_size, args)
        ret = calling_class.respond(conn.public_send(method, *p_args))

        return ret unless ret.more_items?

        loop do
          offset += page_size
          p_args = set_pagination(offset, page_size, p_args)
          resp = calling_class.respond(conn.public_send(method, *p_args))
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
      # rubocop:disable Metrics/MethodLength
      def make_lazy_call
        offset = 0
        p_args = set_pagination(offset, page_size, args)

        Enumerator.new do |y|
          loop do
            offset += page_size
            resp = calling_class.respond(conn.public_send(method, *p_args))
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
