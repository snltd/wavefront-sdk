require_relative 'core/write'

module Wavefront
  #
  # This class helps you send points to a Wavefront proxy in native
  # format. Usually this is done on port 2878.
  #
  # The points are prepped in the BaseWrite class, which this
  # extends. This class provides the transport mechanism.
  #
  class Write < CoreWrite
    attr_reader :net

    def really_send_point(point)
      begin
        sock.puts(point)
      rescue StandardError => e
        summary[:unsent] += 1
        log('WARNING: failed to send point.')
        log(e.to_s, :debug)
        return false
      end

      summary[:sent] += 1
      true
    end

    # Open a socket to a Wavefront proxy, putting the descriptor
    # in instance variable @sock.
    #
    def open
      if opts[:noop]
        log('No-op requested. Not opening connection to proxy.')
        return true
      end

      port = net[:port] || 2878
      log("Connecting to #{net[:proxy]}:#{port}.", :debug)

      begin
        @sock = TCPSocket.new(net[:proxy], port)
      rescue StandardError => e
        log(e, :error)
        raise Wavefront::Exception::InvalidEndpoint
      end
    end

    # Close the socket described by the @sock instance variable.
    #
    def close
      return if opts[:noop]
      log('Closing connection to proxy.', :debug)
      sock.close
    end

    # Overload the method which sets an API endpoint. A proxy
    # endpoint has an address and a port, rather than an address and
    # a token.
    #
    def setup_api(creds, _opts)
      @net = creds
    end

    # Send raw data to a Wavefront proxy, automatically opening and
    # closing a socket.
    #
    # @param points [Array[String]] an array of points in native
    #   Wavefront wire format, as described in
    #   https://community.wavefront.com/docs/DOC-1031. No validation
    #   is performed.
    # @param openclose [Boolean] whether or not to automatically
    #   open a socket to the proxy before sending points, and
    #   afterwards, close it.
    #
    def raw(points, openclose = true)
      open if openclose

      begin
        [points].flatten.each { |p| send_point(p) }
      ensure
        close if openclose
      end
    end

    def validate_credentials(creds)
      return true if creds.key?(:proxy)
      raise(Wavefront::Exception::CredentialError,
            'credentials must contain proxy')
    end

    private

    def _write_loop(points)
      points.each do |p|
        p[:ts] = p[:ts].to_i if p[:ts].is_a?(Time)
        send_point(hash_to_wf(p))
      end
    end
  end
end
