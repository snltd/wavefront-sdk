require_relative './base'

module Wavefront
  #
  # Manage and query Wavefront searches. The /search API path has a
  # lot of paths, with a lot of duplication. The current state of
  # this class covers the whole API with two methods, but leaves a
  # lot up to the user. It may grow, with convenience methods.
  #
  class Search < Base

    # POST /api/v2/search/agent
    # POST /api/v2/search/agent/deleted
    # Run a search query. This single method maps to many API paths.
    #
    # @param entity [String] the type of Wavefront object you wish
    #   to search
    # @param body [Hash] the query to use for searching. Refer to
    #   the Wavefront Swagger docs for the correct format.
    # @param deleted [Boolean] whether to search deleted (true) or
    #   active (false) entities
    #
    def search(entity = nil, body = nil, deleted = false)
      raise ArgumentError unless entity.is_a?(String)
      raise ArgumentError unless body.is_a?(Hash)
      path = ['agent']
      path.<< 'deleted' if deleted
      api_post(path, body, 'application/json')
    end

    # @param entity [String] the type of Wavefront object you wish
    #   to search
    # @param body [Hash] the query to use for searching. Refer to
    #   the Wavefront Swagger docs for the correct format.
    # @param deleted [Boolean] whether to search deleted (true) or
    #   active (false) entities
    # @param facet [String] the facet on which to search. If this is
    #   false, the assumption is that multiple facets will be
    #   specified in the body. See the Swagger docs for more
    #   information.
    #
    def facet_search(entity = nil, body = nil, deleted = false,
                     facet = false)
      raise ArgumentError unless entity.is_a?(String)
      raise ArgumentError unless body.is_a?(Hash)
      path = ['agent']
      path.<< 'deleted' if deleted
      path.<< facet ? facet : 'facets'
      api_post(path, body, 'application/json')
    end
  end
end
