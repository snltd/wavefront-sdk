# frozen_string_literal: true

require_relative 'core'

module Wavefront
  module Writer
    #
    # Everything specific to writing points to a Wavefront proxy, in
    # native Wavefront format, to a socket. (The original and,
    # once, only way to send points.)
    #
    class Socket < Core
      # Open a socket to a Wavefront proxy, putting the descriptor
      # in instance variable @conn.
      # @return [TCPSocket]
      #
      # rubocop:disable Metrics/AbcSize
      def open
        if opts[:noop]
          logger.log('No-op requested. Not opening connection to proxy.')
          return true
        end

        port = creds[:port] || default_port
        logger.log("Connecting to #{creds[:proxy]}:#{port}.", :debug)

        begin
          @conn = TCPSocket.new(creds[:proxy], port)
        rescue StandardError => e
          logger.log(e, :error)
          raise Wavefront::Exception::InvalidEndpoint
        end
      end
      # rubocop:enable Metrics/AbcSize

      # Close the connection described by the @conn instance variable.
      #
      def close
        return if opts[:noop]

        logger.log('Closing connection to proxy.', :debug)
        conn.close
      end

      def validate_credentials(creds)
        return true if creds.key?(:proxy)

        raise(Wavefront::Exception::CredentialError,
              'creds must contain proxy address')
      end

      private

      # @param point [String] point or points in native Wavefront format.
      # @raise [SocketError] if point cannot be written
      #
      def _send_point(point)
        return if opts[:noop]

        conn.puts(point)
      rescue StandardError
        raise Wavefront::Exception::SocketError
      end

      # return [Integer] the port to connect to, if none is supplied
      #
      def default_port
        2878
      end
    end
  end
end
