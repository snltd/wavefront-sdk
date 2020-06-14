# frozen_string_literal: true

require_relative 'defs/constants'
require_relative 'core/api'

module Wavefront
  #
  # Spy on data going into Wavefront
  #
  class Spy < CoreApi
    # GET /api/spy/points
    # Gets new metric data points that are added to existing time series.
    # @param sampling [Float] the amount of points to sample, from 0
    #   (none) to 1 (all)
    # @param filter [Hash] with the following keys:
    #   :prefix [String] only list points whose metric name begins with this
    #     case-sensitive string
    #   :host [Array] only list points if source name begins with this
    #     case-sensitive string
    #   :tag_key [String,Array[String]] only list points with one or more of
    #     the given points tags
    # @param options [Hash] with the following keys
    #   :timestamp [Boolean] prefix each block of streamed data with a
    #     timestamp
    #   :timeout [Integer] how many seconds to run the spy. After this time
    #     the method returns
    # @raise Wavefront::Exception::InvalidSamplingValue
    # @return [Nil]
    #
    def points(sampling = 0.01, filters = {}, options = {})
      wf_sampling_value?(sampling)
      api.get_stream('points', points_filter(sampling, filters), options)
    end

    # GET /api/spy/histograms
    # Gets new histograms that are added to existing time series.
    # @param sampling [Float] see #points
    # @param filter [Hash] see #points
    # @param options [Hash] see #points
    # @raise Wavefront::Exception::InvalidSamplingValue
    # @return [Nil]
    #
    def histograms(sampling = 0.01, filters = {}, options = {})
      wf_sampling_value?(sampling)
      api.get_stream('histograms',
                     histograms_filter(sampling, filters),
                     options)
    end

    # GET /api/spy/spans
    # Gets new spans with existing source names and span tags.
    # @param sampling [Float] see #points
    # @param filter [Hash] see #points
    # @param options [Hash] see #points
    # @raise Wavefront::Exception::InvalidSamplingValue
    # @return [Nil]
    #
    def spans(sampling = 0.01, filters = {}, options = {})
      wf_sampling_value?(sampling)
      api.get_stream('spans', spans_filter(sampling, filters), options)
    end

    # GET /api/spy/ids
    # Gets newly allocated IDs that correspond to new metric names, source
    # names, point tags, or span tags. A new ID generally indicates that a
    # new time series has been introduced.
    # @param sampling [Float] see #points
    # @param filter [Hash] with keys:
    #   :prefix [String] only list assignments whose metric name begins with
    #     this case-sensitive string
    #   :type [String] one of METRIC, SPAN, HOST or STRING
    # @param options [Hash] see #points
    #
    def ids(sampling = 0.01, filters = {}, options = {})
      wf_sampling_value?(sampling)
      api.get_stream('ids', ids_filter(sampling, filters), options)
    end

    def api_path
      '/api/spy'
    end

    # We have to try to make the response we get from the API look
    # like the one we get from the public API. To begin with, it's
    # nothing like it.
    #
    # This method must be public because a #respond_to? looks for
    # it.
    #
    def _response_shim(resp, status)
      { response: parse_response(resp),
        status: { result: status == 200 ? 'OK' : 'ERROR',
                  message: extract_api_message(status, resp),
                  code: status } }.to_json
    end

    private

    def points_filter(sampling, filters)
      { metric: filters.fetch(:prefix, nil),
        host: filters.fetch(:host, nil),
        sampling: sampling,
        pointTagKey: filters.fetch(:tag_key, nil) }.compact
    end

    def histograms_filter(sampling, filters)
      { histogram: filters.fetch(:prefix, nil),
        host: filters.fetch(:host, nil),
        sampling: sampling,
        histogramTagKey: filters.fetch(:tag_key, nil) }.compact
    end

    def spans_filter(sampling, filters)
      { name: filters.fetch(:prefix, nil),
        host: filters.fetch(:host, nil),
        sampling: sampling,
        spanTagKey: filters.fetch(:tag_key, nil) }.compact
    end

    def ids_filter(sampling, filters)
      { name: filters.fetch(:prefix, nil),
        type: filters.fetch(:type, nil),
        sampling: sampling }.compact
    end
  end
end
