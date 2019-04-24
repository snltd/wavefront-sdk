require_relative 'base'

module Wavefront
  module MetricType
    # Dists
    class Distribution < Base
      # @return [Hash] options hash, with :port replaced by :dist_port
      #
      def dist_creds(creds)
        creds.dup.tap { |o| o[:port] = metric_opts[:dist_port] }
      end

      def setup_writer(creds, writer_opts)
        require_relative 'distribution'
        Wavefront::Distribution.new(dist_creds(creds), writer_opts)
      end

      def q(path, interval, value, tags = nil)
        key = [path, interval, tags]
        qq(path:   path,
           ts:     Time.now.utc.to_i,
           value:  value,
           source: HOSTNAME,
           tags:   tags)
      end

      def qq()
      end

      def flush!(dists)
        return if dists.empty?

        to_flush = dists.dup
        @buf[:dists] = empty_dists

        dist_writer.write(dists_to_wf(dists)).tap do |resp|
          replay_dists(to_flush) unless resp.ok?
        end
      end

      def to_wf(dists)
        dists.map do |k, v|
          path, interval, tags = k
          dist = { path:     path,
                   value:    dist_writer.mk_distribution(v),
                   ts:       Time.now.utc.to_i,
                   interval: interval }
          dist[:tags] = tags unless tags.nil?
          dist
        end
      end

      def replay(buffer)
        buffer.each { |k, v| dist(k[0], k[1], v, k[2]) }
      end
    end
  end
end
