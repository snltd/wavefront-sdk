require_relative 'core'
require_relative '../core/api_caller'

module Wavefront
  module Writer
    #
    # Send points direct to Wavefront's API. This requires an
    # endpoint, a token, and HTTPS egress.
    #
    class Api < Core
      def open
        @conn = Wavefront::ApiCaller.new(self, creds, opts)
      end

      def api_path
        '/report'
      end

      def validate_credentials(creds)
        unless creds.key?(:endpoint)
          raise(Wavefront::Exception::CredentialError,
                'credentials must contain API endpoint')
        end

        return true if creds.key?(:token)

        raise(Wavefront::Exception::CredentialError,
              'credentials must contain API token')
      end

      def send_point(body)
        _send_point(body)
        summary.sent += body.size
        true
      rescue StandardError => e
        summary.unsent += body.size
        logger.log('WARNING: failed to send point(s).')
        logger.log(e.to_s, :debug)
        false
      end

      def chunk_size
        100
      end

      private

      def write_loop(points)
        body = points.map do |p|
          p[:ts] = p[:ts].to_i if p[:ts].is_a?(Time)
          hash_to_wf(p)
        end

        send_point(body)
      end

      # Send points. We used to batch here but now it's done in the
      # calling class.
      # @param body [Array] array of formatted points
      #
      def _send_point(body)
        conn.post("/?f=#{calling_class.data_format}",
                  body.join("\n"),
                  'application/octet-stream')
      end
    end
  end
end
