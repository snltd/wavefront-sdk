require 'pathname'
require 'inifile'

module Wavefront

  # Helper methods to get Wavefront credentials
  #
  class Credentials
    attr_reader :opts

    # Returns you a hash of credentials for Wavefront. It will look
    # in the following places:
    #
    # ~/.wavefront
    # /etc/wavefront/credentials
    # WAVEFRONT_ENDPOINT and WAVEFRONT_TOKEN environment variables
    #
    # @param options [Hash] can have keys
    #   file [Pathname, String] the path to a config file to search
    #   profile [String] the profile inside the config file
    #   only_creds [Bool] whether to only return endpoint and token
    #   information rather than the entire contents of a config
    #   file.
    #
    def initialize(options = { only_creds: true })
      @opts = options

      ret = load_from_file || {}

      if ENV['WAVEFRONT_ENDPOINT']
        ret[:endpoint] = ENV['WAVEFRONT_ENDPOINT']
      end

      ret[:token] = ENV['WAVEFRONT_TOKEN'] if ENV['WAVEFRONT_TOKEN']
    end

    def load_from_file
      conf = false

      profile = opts[:profile] || 'default'

      c_file = if opts[:file]
                 Array(Pathname.new(file))
               else
                 [Pathname.new('/etc/wavefront/credentials'),
                  Pathname.new(ENV['HOME']) + '.wavefront']
               end

      c_file.each do |f|
        conf = load_config(f, profile) if f.exist?
      end

      filter_config(conf)
    end

    def filter_config(conf)
      if opts[:only_creds]
        conf.select! { |k, _v| k == :endpoint || k == :token }
      end

      conf
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
