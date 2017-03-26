module Wavefront
  #
  # Simple exception classes
  #
  class Exception
    class InvalidTimeFormat < ::Exception; end
    class InvalidGranularity < ::Exception; end
    class InvaldResponseFormat < ::Exception; end
    class EmptyMetricName < ::Exception; end
    class NotImplemented < ::Exception; end
    class InvalidPrefixLength < ::Exception; end
    class InvalidMetricName < ::Exception; end
    class InvalidMetricValue < ::Exception; end
    class InvalidTimestamp < ::Exception; end
    class InvalidTag < ::Exception; end
    class InvalidHostname < ::Exception; end
    class InvalidEndpoint < ::Exception; end
    class InvalidSource < ::Exception; end
    class InvalidString < ::Exception; end
    class InvalidAgent < ::Exception; end
    class InvalidAlert < ::Exception; end
    class ValueOutOfRange < ::Exception; end
  end
end
