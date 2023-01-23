# frozen_string_literal: true

require_relative 'core'
require_relative '../core/api_caller'

module Wavefront
  module Writer
    #
    # Send points direct to Wavefront's API. This requires an endpoint, a
    # token, and HTTPS egress.
    #
    # Points are sent in batches of BATCH_SIZE. We attempt to make a summary
    # of how many points are sent or rejected, but it's quantized by the batch
    # size.
    #
    # TODO I think this needs a composite response. It makes one or more API
    # calls depending on the amount of metrics to be sent, and the CLI needs
    # to know if there was anything other than a 200. Options are to return
    # the first failure when it happens, or to try all the chunks and return
    # the last non-200, or the highest numbered return code, or some other
    # indication of failure.
    #
    class Api < Core
      BATCH_SIZE = 2

      def open
        @conn = Wavefront::ApiCaller.new(self, creds, opts)
      end

      def api_path
        '/report'
      end

      def validate_credentials(creds)
        unless creds.key?(:endpoint) && creds[:endpoint]
          raise(Wavefront::Exception::CredentialError,
                'credentials must contain API endpoint')
        end

        return true if creds.key?(:token) && creds[:token]

        raise(Wavefront::Exception::CredentialError,
              'credentials must contain API token')
      end

      def send_point(body)
        _send_point(body)
        true
      rescue StandardError => e
        puts "MERP"
        summary.unsent += body.size
        logger.log('WARNING: failed to send point(s).')
        logger.log(e.to_s, :debug)
        false
      end

      private

      def write_loop(points)
        body = points.map do |p|
          p[:ts] = p[:ts].to_i if p[:ts].is_a?(Time)
          hash_to_wf(p)
        end

        send_point(body)
      end

      # Send points in batches of BATCH_SIZE. I'm not sure exactly how much the
      # API can cope with in a single call, so this might change.
      # @return [Nil]
      #
      def _send_point(body)
        body.each_slice(BATCH_SIZE) do |p|
          ret = conn.post('/?f=wavefront', p.join("\n"), 'application/octet-stream')

          if ret.ok?
            summary.sent += p.count
          else
            summary.unsent += p.count
          end
        end
      end
    end
  end
end
