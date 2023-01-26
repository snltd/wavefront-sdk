# frozen_string_literal: true

require 'faraday'
require 'pathname'

module Wavefront
  #
  # Methods to inspect the SDK itselr.
  #
  class Internals
    API_REGEX = %r{^\s+ # (GET|POST|PUT|DELETE|PATCH) /}.freeze

    # @return [Array[Pathname]] SDK API files
    #
    def sdk_files
      Pathname.glob("#{__dir__}/**/*")
              .select { |f| f.file? && f.extname == '.rb' }
              .reject { |f| f == Pathname.new(__FILE__) }
    end

    # @return [Array[String]] list of all the remote API paths the SDK covers.
    # Depends on the code being commented correctly, so not 100% bulletproof.
    #
    # rubocop:disable Metrics/AbcSize
    def supported_api_paths
      mix = { acl: [], tag: [], user: [] }
      searches = []

      paths = sdk_files.map do |f|
        lines = File.readlines(f)
        searches << f if lines.grep('CoreApi')
        mix.each_key { |m| mix[m] << f if lines.grep(%r{"api_mixins/#{m}"}) }
        lines.grep(API_REGEX)
      end

      clean = paths_struct(clean_paths(paths))
      clean + mixin_paths(clean, mix) + search_paths(clean, searches)
    end
    # rubocop:enable Metrics/AbcSize

    def clean_paths(paths)
      paths.flatten.compact.map { |s| s.strip.sub(/^# /, '') }
    end

    def search_paths(paths, files)
      search_paths = paths.select { |_v, x| x.include?('/search/') }

      search_paths.each_with_object([]) do |(verb, path), ret|
        files.each { |f| ret << [verb, path.sub('{entity}', api_word(f))] }
      end
    end

    def remote_api_paths(spec = swagger_spec)
      paths = JSON.parse(spec)['paths'].map do |path, data|
        data.keys.map { |verb| [verb.upcase, path].join(' ') }
      end

      paths_struct(paths.flatten)
    end

    def missing_api_paths
      remote_api_paths - supported_api_paths
    end

    private

    def mixin_paths(paths, mixins)
      mixins.each_with_object([]) do |(mixin, files), ret|
        files.each do |file|
          paths.select { |_v, x| x.include?(mixin.to_s) }.each do |verb, path|
            ret << [verb, path.sub('{entity}', api_word(file))]
          end
        end
      end
    end

    def api_word(file)
      file.basename.to_s.sub(/\.rb$/, '')
    end

    def swagger_spec
      Faraday.get('https://metrics.wavefront.com/api/v2/swagger.json').body
    end

    def paths_struct(paths)
      paths.map(&:split).sort_by { |_k, v| v }
    end
  end
end
