# frozen_string_literal: true

module Wavefront
  #
  # Simple exception classes
  #
  class Exception
    class CredentialError < RuntimeError; end

    class EmptyMetricName < RuntimeError; end

    class EnumerableError < RuntimeError; end

    class InvalidAccountId < RuntimeError; end

    class InvalidAlertId < RuntimeError; end

    class InvalidAlertSeverity < RuntimeError; end

    class InvalidApiTokenId < RuntimeError; end

    class InvalidAwsExternalId < RuntimeError; end

    class InvalidConfigFile < RuntimeError; end

    class InvalidCloudIntegrationId < RuntimeError; end

    class InvalidDashboardId < RuntimeError; end

    class InvalidDerivedMetricId < RuntimeError; end

    class InvalidDistribution < RuntimeError; end

    class InvalidDistributionInterval < RuntimeError; end

    class InvalidDistributionCount < RuntimeError; end

    class InvalidEndpoint < RuntimeError; end

    class InvalidEventId < RuntimeError; end

    class InvalidExternalLinkId < RuntimeError; end

    class InvalidGranularity < RuntimeError; end

    class InvalidHostname < RuntimeError; end

    class InvalidIngestionPolicyId < RuntimeError; end

    class InvalidIntegrationId < RuntimeError; end

    class InvalidLinkTemplate < RuntimeError; end

    class InvalidMaintenanceWindowId < RuntimeError; end

    class InvalidMonitoredApplicationId < RuntimeError; end

    class InvalidMonitoredClusterId < RuntimeError; end

    class InvalidMessageId < RuntimeError; end

    class InvalidMetricName < RuntimeError; end

    class InvalidMetricsPolicyId < RuntimeError; end

    class InvalidMetricValue < RuntimeError; end

    class InvalidName < RuntimeError; end

    class InvalidNotificantId < RuntimeError; end

    class InvalidPermission < RuntimeError; end

    class InvalidPoint < RuntimeError; end

    class InvalidPrefixLength < RuntimeError; end

    class InvalidProxyId < RuntimeError; end

    class InvalidRoleId < RuntimeError; end

    class InvalidRelativeTime < RuntimeError; end

    class InvalidSamplingValue < RuntimeError; end

    class InvalidSavedSearchEntity < RuntimeError; end

    class InvalidSavedSearchId < RuntimeError; end

    class InvalidServiceAccountId < RuntimeError; end

    class InvalidSourceId < RuntimeError; end

    class InvalidSpanSamplingPolicyId < RuntimeError; end

    class InvalidString < RuntimeError; end

    class InvalidTag < RuntimeError; end

    class InvalidTimeFormat < RuntimeError; end

    class InvalidTimeUnit < RuntimeError; end

    class InvalidTimestamp < RuntimeError; end

    class InvalidUserId < RuntimeError; end

    class InvalidUserGroupId < RuntimeError; end

    class InvalidVersion < RuntimeError; end

    class InvalidWebhookId < RuntimeError; end

    class MissingConfigProfile < RuntimeError; end

    class NetworkTimeout < RuntimeError; end

    class NotImplemented < RuntimeError; end

    class SocketError < RuntimeError; end

    class UnparseableResponse < RuntimeError; end

    class UnsupportedWriter < RuntimeError; end

    class ValueOutOfRange < RuntimeError; end
  end
end
