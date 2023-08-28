# frozen_string_literal: true

require_relative 'core/api'

module Wavefront
  #
  # Query Wavefront cluster info. The API docs call this "wavefront", but that
  # confuses everything.
  #
  class Cluster < CoreApi
    # GET /api/v2/cluster/info
    # get cluster info
    #
    def describe
      api.get('info')
    end
  end
end
