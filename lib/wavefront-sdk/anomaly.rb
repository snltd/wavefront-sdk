require_relative 'core/api'
require_relative 'stdlib/time'

module Wavefront
  #
  # View anomalies.
  #
  # Note that these methods are called in a slightly different way
  # to methods in similar classes, to keep the number of arguments
  # to a sensible limit. The offset, limit, and time range are
  # described in an options hash rather than as separate args.
  #
  class Anomaly < CoreApi
    # All Wavefront::Anomaly methods expect to take an options hash
    # which describes the range of the query. It has the following
    # keys:
    #   offset [Integer] anomaly metric at which the list begins
    #   limit [Integer] the number of anomalies to return
    #   start_ms [Integer] start of time interval
    #   end_ms [Integer] end of time interval
    #
    # This method sets default values for any which are not set.
    #
    def defaults(options = {})
      options.tap do |o|
        o[:offset]  ||= 0
        o[:limit]   ||= 100
        o[:startMs] ||= Time.now.to_ms
        o[:endMs]   ||= Time.now.to_ms
      end
    end

    # GET /api/v2/anomaly
    # Get all anomalies for a customer during a time interval
    #
    # @param options [Hash] see #defaults
    # @return [Wavefront::Response]
    #
    def list(options = {})
      api.get('', defaults(options))
    end

    # XXX TODO I don't know what a paramHash or chartHash look like,
    # and I haven't been able to find any anomalies through the API
    # yet.

    # GET /api/v2/anomaly/{dashboardId}
    # Get all anomalies for a dashboard that does not have any
    # dashboard parameters during a time interval
    # GET /api/v2/anomaly/{dashboardId}/{paramHash}
    # Get all anomalies for a dashboard with a particular set of
    # dashboard parameters as identified by paramHash, during a time
    # interval
    #
    # @param dashboard_id [String] dashboard ID
    # @param param_hash [String]
    # @param options [Hash] see #defaults
    # @return [Wavefront::Response]
    #
    def dashboard(dashboard_id, param_hash = nil, options = {})
      wf_dashboard_id?(dashboard_id)
      api.get([dashboard_id, param_hash].uri_concat, defaults(options))
    end

    # GET /api/v2/anomaly/{dashboardId}/chart/{chartHash}
    # Get all anomalies for a chart during a time interval
    # GET /api/v2/anomaly/{dashboardId}/chart/{chartHash}/{paramHash}
    # Get all anomalies for a chart with a set of dashboard
    # parameters during a time interval
    #
    # @param dashboard_id [String] dashboard ID
    # @param param_hash [String]
    # @param chart_hash [String]
    # @return [Wavefront::Response]
    #
    def chart(dashboard_id, chart_hash = nil, param_hash = nil,
              options = {})
      wf_dashboard_id?(dashboard_id)
      api.get([dashboard_id, 'chart', chart_hash, param_hash].uri_concat,
              defaults(options))
    end
  end
end
