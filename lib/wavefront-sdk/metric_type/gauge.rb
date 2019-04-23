require_relative 'base'

module Wavefront
  module MetricType
    #
    # Gauge metrics are a standard Wavefront point. A metric path, a
    # value, and maybe some tags. Remember that Wavefront has a
    # one-second resolution.
    #
    class Gauge < Base
      def ready_point(point)
        point
      end
    end
  end
end
