# frozen_string_literal: true

require 'socket'
require_relative 'core'

module Wavefront
  module Writer
    #
    # Everything specific to writing points to a Unix datagram socket.
    #
    class Unix < Core
      # Make a connection to a Unix datagram socket, putting the
      # descriptor in instance variable @conn.
      # This requires the name of the socket file in creds[:socket]
      # @return [UnixSocket]
      #
      def open
        if opts[:noop]
          logger.log('No-op requested. Not opening socket connection.')
          return true
        end

        logger.log("Connecting to #{creds[:socket]}.", :debug)
        open_socket(creds[:socket])
      end

      def close
        return if opts[:noop]

        logger.log('Closing socket connection.', :debug)
        conn.close
      end

      def validate_credentials(creds)
        return true if creds.key?(:socket) && creds[:socket]

        raise(Wavefront::Exception::CredentialError,
              'credentials must contain socket file path')
      end

      private

      def open_socket(socket)
        @conn = UNIXSocket.new(socket)
      rescue StandardError => e
        logger.log(e, :error)
        raise Wavefront::Exception::InvalidEndpoint
      end

      # @param point [String] point or points in native Wavefront format.
      #
      def _send_point(point)
        return if opts[:noop]

        conn.write(point)
      end
    end
  end
end
