module Wavefront
  #
  # Simple exception classes
  #
  class Exception
    class EmptyMetricName < RuntimeError; end
    class InvalidAlertId < RuntimeError; end
    class InvalidAlertSeverity < RuntimeError; end
    class InvalidCloudIntegrationId < RuntimeError; end
    class InvalidDashboardId < RuntimeError; end
    class InvalidDerivedMetricId < RuntimeError; end
    class InvalidEndpoint < RuntimeError; end
    class InvalidEventId < RuntimeError; end
    class InvalidExternalLinkId < RuntimeError; end
    class InvalidGranularity < RuntimeError; end
    class InvalidHostname < RuntimeError; end
    class InvalidIntegrationId < RuntimeError; end
    class InvalidRelativeTime < RuntimeError; end
    class InvalidTimeUnit < RuntimeError; end
    class InvalidMaintenanceWindowId < RuntimeError; end
    class InvalidMessageId < RuntimeError; end
    class InvalidMetricName < RuntimeError; end
    class InvalidMetricValue < RuntimeError; end
    class InvalidNotificantId < RuntimeError; end
    class InvalidName < RuntimeError; end
    class InvalidPoint < RuntimeError; end
    class InvalidPrefixLength < RuntimeError; end
    class InvalidProxyId < RuntimeError; end
    class InvalidSavedSearchId < RuntimeError; end
    class InvalidSavedSearchEntity < RuntimeError; end
    class InvalidSourceId < RuntimeError; end
    class InvalidString < RuntimeError; end
    class InvalidTag < RuntimeError; end
    class InvalidLinkTemplate < RuntimeError; end
    class InvalidTimeFormat < RuntimeError; end
    class InvalidTimestamp < RuntimeError; end
    class InvalidUserId < RuntimeError; end
    class InvalidWebhookId < RuntimeError; end
    class InvalidVersion < RuntimeError; end
    class NotImplemented < RuntimeError; end
    class UnparseableResponse < RuntimeError; end
    class ValueOutOfRange < RuntimeError; end
  end
end
