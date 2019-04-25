require_relative 'core'
require_relative '../core/api_caller'

module Wavefront
  module Writer
    #
    # HTTP POST points to a local proxy. This method does not
    # support any authentication or authorization, as these are not
    # supported by the proxy at the time of writing. When the proxy
    # acquires these functions, a new writer will be made.
    #
    class Http < Core
      def open
        creds[:endpoint] = format('%s:%s', creds[:proxy],
                                  creds[:port] || default_port)
        opts[:scheme] = 'http'
        @conn = Wavefront::ApiCaller.new(self, creds, opts)
      end

      def api_path
        nil
      end

      def default_port
        2878
      end

      def validate_credentials(creds)
        return true if creds.key?(:proxy)

        raise(Wavefront::Exception::CredentialError,
              'credentials must contain proxy')
      end

      def chunk_size
        100
      end

      private

      def _send_point(point)
        conn.post(nil, point).ok?
      end
    end
  end
end
