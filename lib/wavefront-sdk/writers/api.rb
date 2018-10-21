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

      private

      def _send_point(point)
        conn.post('/?f=wavefront', point, 'application/octet-stream')
      end
    end
  end
end
