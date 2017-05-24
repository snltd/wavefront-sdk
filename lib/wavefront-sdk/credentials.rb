require 'pathname'
require 'inifile'
require 'ostruct'

module Wavefront

  # Helper methods to get Wavefront credentials
  #
  class Credentials
    attr_reader :opts, :conf, :to_obj

    # Gives you an object or hash of credentials and options for speaking to
    # Wavefront. It will look in the following places:
    #
    # ~/.wavefront
    # /etc/wavefront/credentials
    # WAVEFRONT_ENDPOINT and WAVEFRONT_TOKEN environment variables
    #
    # @param options [Hash] keys may be 'file', which
    #   specifies a config file which will be loaded and parsed. If no file is
    #   supplied, those listed above will be used.; and/or 'profile' which select a
    #   profile section from 'file'
    #
    def initialize(options = {})
      @opts = options
      conf = load_from_file || {}
      conf[:endpoint] = ENV['WAVEFRONT_ENDPOINT'] if ENV['WAVEFRONT_ENDPOINT']
      conf[:token] = ENV['WAVEFRONT_TOKEN'] if ENV['WAVEFRONT_TOKEN']
      @conf = conf
    end

    def to_hash
      { config: conf,
        creds: conf.select { |k, _v| [:endpoint, :token].include?(k) },
        proxy: conf.select { |k, _v| [:proxy, :port].include?(k) } }
    end

    def to_obj
      OpenStruct.new(to_hash)
    end

    def load_from_file
      ret = {}

      profile = opts[:profile] || 'default'

      c_file = if opts.key?(:file)
                 Array(Pathname.new(opts[:file]))
               else
                 [Pathname.new('/etc/wavefront/credentials'),
                  Pathname.new(ENV['HOME']) + '.wavefront']
               end

      c_file.each do |f|
        next unless f.exist?
        ret = load_profile(f, profile)
        ret[:file] = f
      end

      ret
    end

    # Load in configuration (optionally) given section of an
    # ini-style configuration file not there, we don't consider that
    # an error.
    #
    # @param file [Pathname] the file to read
    # @param profile [String] the section in the config to read
    # @return [Hash] options loaded from file. Each key becomes a
    #   symbol
    #
    def load_profile(file, profile = 'default')
      IniFile.load(file)[profile].each_with_object({}) do |(k, v), memo|
        memo[k.to_sym] = v
      end
    end
  end
end
