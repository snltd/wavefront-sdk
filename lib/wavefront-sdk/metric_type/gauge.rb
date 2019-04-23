require_relative 'base'

module Wavefront
  module MetricType
    #
    # Gauge metrics are a standard Wavefront point. A metric path, a
    # value, and maybe some tags.
    #
    class Gauge < Base; end
  end
end
