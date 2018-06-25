require_relative 'base'

module Wavefront
  #
  # Query Wavefront metrics.
  #
  class Metric < Base
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
      raise ArgumentError unless metric.is_a?(String)
      raise ArgumentError unless sources.is_a?(Array)

      q = [[:m, metric]]

      if cursor
        raise ArgumentError unless cursor.is_a?(String)
        q.<< [:c, cursor]
      end

      sources.each { |s| q.<< [:h, s] }

      api_get('detail', q)
    end
  end
end
