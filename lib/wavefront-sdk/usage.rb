# frozen_string_literal: true

require_relative 'core/api'

module Wavefront
  #
  # View and manage Wavefront usage.
  #
  # Ingestion policy shares this API path, but has its own SDK class.
  #
  class Usage < CoreApi
    # GET /api/v2/usage/exportcsv
    # Export a CSV report
    #
    # @param t_start [Integer] start time in epoch seconds
    # @param t_end [Integer] end time in epoch seconds, nil being "now".
    # @return [Wavefront::Response]
    #
    def export_csv(t_start, t_end = nil)
      wf_epoch?(t_start)
      args = { startTime: t_start }

      if t_end
        wf_epoch?(t_end)
        args[:endTime] = t_end
      end

      api.get('exportcsv', args)
    end
  end
end
