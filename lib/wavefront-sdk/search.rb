require_relative 'core/api'

module Wavefront
  #
  # Manage and query Wavefront searches. The /search API path has a
  # lot of paths, with a lot of duplication. The current state of
  # this class covers the whole API with two methods, but leaves a
  # lot up to the user. It may grow, with convenience methods.
  #
  class Search < CoreApi
    # POST /api/v2/search/entity
    # POST /api/v2/search/entity/deleted
    # Run a search query. This single method maps to many API paths.
    # It is a wrapper around #raw_search() for common, single
    # key-value searches. If you need to do more complicated things,
    # use #raw_search().
    #
    # @param entity [String, Symbol] the type of Wavefront object
    #   you wish to search. e.g. :alert, :dashboard
    # @param query [Array, Hash] A single hash, or array of hashes,
    # containing the following keys:
    #   key [String] the field on which to search
    #   value [String] what to search for
    #   matchingMethod [String] the method to match values. Defaults
    #     to 'CONTAINS'. Must be one of CONTAINS, STARTSWITH, EXACT,
    #     TAGPATH
    #   If an array of hashes is supplied, Wavefront will apply a
    #   logical AND to the given key-value pairs.
    # @param value [String] the value to search for
    # @param options [Hash] tune the query: keys are:
    #   deleted [Boolean] whether to search deleted (true) or active
    #     (false) entities
    #   limit [Integer] how many results to return. Defaults to 0
    #     (all of them)
    #   offset [Integer] return results after this offset
    #   desc: [Boolean] return results in descending order. Defaults
    #     to false. Sorting is done on the 'key' of the first query
    #     hash.
    #
    def search(entity, query, options = {})
      raise ArgumentError unless options.is_a?(Hash)
      raw_search(entity, body(query, options), options[:deleted] || false)
    end

    # Build a query body
    #
    def body(query, options)
      ret = { limit:  options[:limit]  || 10,
              offset: options[:offset] || 0 }

      if query && !query.empty?
        ret[:query] = [query].flatten.map do |q|
          q.tap { |iq| iq[:matchingMethod] ||= 'CONTAINS' }
        end

        ret[:sort] = sort_field(options, query)
      end

      ret
    end

    def sort_field(options, query)
      field = options[:sort_field] || [query].flatten.first[:key]

      { field:     field,
        ascending: !options[:desc] || true }
    end

    # POST /api/v2/search/entity
    # POST /api/v2/search/entity/deleted
    # Run a search query. This single method maps to many API paths.
    #
    # @param entity [String] the type of Wavefront object you wish
    #   to search
    # @param body [Hash] the query to use for searching. Refer to
    #   the Wavefront Swagger docs for the correct format.
    #   Specifying multiple key - value pairs performs a logical AND
    #   on the constraints.
    # @param deleted [Boolean] whether to search deleted (true) or
    #   active (false) entities
    #
    def raw_search(entity = nil, body = nil, deleted = false)
      unless (entity.is_a?(String) || entity.is_a?(Symbol)) &&
             body.is_a?(Hash)
        raise ArgumentError
      end

      path = [entity]
      path.<< 'deleted' if deleted
      api.post(path, body, 'application/json')
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
    def raw_facet_search(entity = nil, body = nil, deleted = false,
                         facet = false)
      raise ArgumentError unless entity.is_a?(String) && body.is_a?(Hash)

      path = [entity]
      path.<< 'deleted' if deleted
      path.<< facet || 'facets'
      api.post(path, body, 'application/json')
    end
  end
end
