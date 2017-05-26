require_relative './base'

module Wavefront
  #
  # Query Wavefront metrics.
  #
  class Metric < Wavefront::Base
    def api_base
      'chart/metric'
    end

    # GET /api/v2/chart/metric/detail
    # Get more details on a metric, including reporting sources and
    # approximate last time reported
    #
    # @param offset [Int] agent at which the list begins
    # @param limit [Int] the number of agents to return
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

  class Response
    class Metric < Base; end
  end
end
