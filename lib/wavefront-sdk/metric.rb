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

      qs = [URI.encode(metric)]

      sources.each do |s|
        raise Wavefront::Exception::InvalidSource unless wf_source?(s)
        qs.<< "h=#{s}"
      end

      qs.<< "c=#{cursor}" unless cursor.empty?

      api_get('detail', URI.encode(qs.join('&')))
    end
  end
end
