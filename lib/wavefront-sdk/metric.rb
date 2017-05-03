require_relative './base'

module Wavefront
  #
  # Query Wavefront metrics.
  #
  class Metric < Wavefront::Base

    # GET /api/v2/chart/metric/detail
    # Get more details on a metric, including reporting sources and
    # approximate last time reported
    #
    # @param offset [Int] agent at which the list begins
    # @param limit [Int] the number of agents to return
    #
    def detail(metric, sources = [], cursor = '')
      raise ArgumentError unless metric.is_a?(String)
      raise ArgumentError unless sources.is_a?(Array)
      raise ArgumentError unless cursor.is_a?(String)

      q = [[:m, metric]]
      q.<< [:c, cursor] unless cursor.empty?

      sources.each do |s|
        raise Wavefront::Exception::InvalidSource unless wf_source_id?(s)
        q.<< [:h, s]
      end

      api_get('detail', q)
    end
  end
end
