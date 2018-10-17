require_relative 'write'

module Wavefront
  #
  # Write points to a local proxy over HTTP. This method does not
  # support authentication or SSL. (These are not supported by the
  # Wavefront proxy at the time of writing.)
  #
  class WriteHttp < Write
    def setup_api(creds, opts)
      opts[:scheme] = 'http'
      creds[:endpoint] = format('%s:%s', creds[:proxy], port)
      Wavefront::ApiCaller.new(self, creds, opts)
    end

    def port
      return creds[:port] if creds[:port]
      return opts[:port] if opts[:port]
      2878
    end

    # POST a point to a proxy
    # @return [Wavefront::Response]
    #
    def really_send_point(point)
      resp = api.post(nil, point, 'application/octet-stream')

      if resp.ok?
        summary[:sent] += 1
      else
        summary[:unsent] += 1
        log('WARNING: failed to post point.')
        log(resp.status.message, :debug)
      end

      resp
    end

    def open; end

    def close; end
  end
end
