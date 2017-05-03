module Wavefront
  #
  # Simple exception classes
  #
  class Exception
    class EmptyMetricName < ::Exception; end
    class InvalidResponseFormat < ::Exception; end
    class InvalidAgent < ::Exception; end
    class InvalidAlert < ::Exception; end
    class InvalidAlertSeverity < ::Exception; end
    class InvalidCloudIntegration < ::Exception; end
    class InvalidDashboard < ::Exception; end
    class InvalidEndpoint < ::Exception; end
    class InvalidEvent < ::Exception; end
    class InvalidExternalLink < ::Exception; end
    class InvalidGranularity < ::Exception; end
    class InvalidHostname < ::Exception; end
    class InvalidMaintenanceWindow < ::Exception; end
    class InvalidMessage < ::Exception; end
    class InvalidMetricName < ::Exception; end
    class InvalidMetricValue < ::Exception; end
    class InvalidName < ::Exception; end
    class InvalidPrefixLength < ::Exception; end
    class InvalidSavedSearch < ::Exception; end
    class InvalidSavedSearchEntity < ::Exception; end
    class InvalidSource < ::Exception; end
    class InvalidString < ::Exception; end
    class InvalidTag < ::Exception; end
    class InvalidLinkTemplate < ::Exception; end
    class InvalidTimeFormat < ::Exception; end
    class InvalidTimestamp < ::Exception; end
    class InvalidVersion < ::Exception; end
    class NotImplemented < ::Exception; end
    class ValueOutOfRange < ::Exception; end
  end
end
