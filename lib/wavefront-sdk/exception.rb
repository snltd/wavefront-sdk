module Wavefront
  #
  # Simple exception classes
  #
  class Exception
    class EmptyMetricName < ::Exception; end
    class InvalidAgentId < ::Exception; end
    class InvalidAlertId < ::Exception; end
    class InvalidAlertSeverity < ::Exception; end
    class InvalidCloudIntegrationId < ::Exception; end
    class InvalidDashboardId < ::Exception; end
    class InvalidEndpoint < ::Exception; end
    class InvalidEventId < ::Exception; end
    class InvalidExternalLinkId < ::Exception; end
    class InvalidGranularity < ::Exception; end
    class InvalidHostname < ::Exception; end
    class InvalidMaintenanceWindowId < ::Exception; end
    class InvalidMessageId < ::Exception; end
    class InvalidMetricName < ::Exception; end
    class InvalidMetricValue < ::Exception; end
    class InvalidName < ::Exception; end
    class InvalidPrefixLength < ::Exception; end
    class InvalidSavedSearchId < ::Exception; end
    class InvalidSavedSearchEntity < ::Exception; end
    class InvalidSourceId < ::Exception; end
    class InvalidString < ::Exception; end
    class InvalidTag < ::Exception; end
    class InvalidLinkTemplate < ::Exception; end
    class InvalidTimeFormat < ::Exception; end
    class InvalidTimestamp < ::Exception; end
    class InvalidUserId < ::Exception; end
    class InvalidWebhookId < ::Exception; end
    class InvalidVersion < ::Exception; end
    class NotImplemented < ::Exception; end
    class ValueOutOfRange < ::Exception; end
  end
end
