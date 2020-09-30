# frozen_string_literal: true

require_relative 'write'
require_relative 'support/mixins'

module Wavefront
  #
  # Help a user write histogram distributions to a Wavefront proxy
  #
  class Distribution < Write
    include Wavefront::Mixins

    # Make a distribution from a lot of numbers. The returned
    # distribution is an array of arrays ready for dropping into
    # #write. If you need a "real" Wavefront representation of the
    # distribution, use #mk_wf_distribution.
    # @param args [String, Array] numbers. Can be multiple
    #   arguments, a whitespace-separated string, or one or more
    #   arrays.
    # @return [Array[Array]] of the form [[1, 3], [4, 5]...]
    #
    def mk_distribution(*args)
      flat = args.flatten
      raw = flat.first.is_a?(String) ? flat.first.split : flat

      hash = raw.each_with_object(Hash.new(0)) do |v, sum|
        sum[v] += 1
        sum
      end

      hash.to_a.map { |a, b| [b, a.to_f] }
    end

    def mk_wf_distribution(*args)
      array2dist(mk_distribution(args))
    end

    def validation
      :wf_distribution?
    end

    def default_port
      40_000
    end

    def data_format
      :histogram
    end

    def data_format
      :histogram
    end

    # Convert a validated point to a string conforming to
    # https://docs.wavefront.com/proxies_histograms.html. No
    # validation is done here.
    #
    # @param dist [Hash] a hash describing a distribution. See
    #   #write() for the format.
    #
    def hash_to_wf(dist)
      logger.log("writer subclass #{writer}", :debug)

      raise unless dist.key?(:interval) && dist.key?(:path)

      format('!%<interval>s %<ts>i %<value>s %<path>s source=%<source>s ' \
             '%<tags>s %<opttags>s', dist_hash(dist)).squeeze(' ').strip
    rescue RuntimeError
      raise Wavefront::Exception::InvalidDistribution
    end

    # rubocop:disable Metrics/AbcSize
    def dist_hash(dist)
      dist.dup.tap do |d|
        d[:interval] = distribution_interval(dist)
        d[:ts] = distribution_timestamp(dist)
        d[:value] = array2dist(dist[:value])
        d[:source] ||= HOSTNAME
        d[:tags] = tags_or_nothing(d[:tags])
        d[:opttags] = tags_or_nothing(opts[:tags])
      end
    end
    # rubocop:enable Metrics/AbcSize

    def distribution_timestamp(dist)
      parse_time(dist.fetch(:ts, Time.now))
    end

    def distribution_interval(dist)
      dist[:interval].to_s.upcase
    end

    # Turn an array of arrays into a the values part of a distribution
    # @return [String]
    #
    def array2dist(values)
      values.map do |x, v|
        format('#%<count>i %<value>s', count: x, value: v)
      end.join(' ')
    end
  end
end
