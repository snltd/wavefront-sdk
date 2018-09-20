require_relative 'core/api'

module Wavefront
  #
  # Query Wavefront metrics.
  #
  class Metric < CoreApi
    def api_base
      'chart/metric'
    end

    # GET /api/v2/chart/metric/detail
    # Get more details on a metric, including reporting sources and
    # approximate last time reported
    #
    # @param metric [String] the metric to fetch
    # @param sources [Array[String]] a list of sources to check.
    # @param cursor [String] optionally begin from this result
    #
    def detail(metric, sources = [], cursor = nil)
      raise ArgumentError unless metric.is_a?(String) && sources.is_a?(Array)

      query = [[:m, metric]]

      if cursor
        raise ArgumentError unless cursor.is_a?(String)
        query.<< [:c, cursor]
      end

      sources.each { |source| query.<< [:h, source] }

      api.get('detail', query)
    end
  end
end
