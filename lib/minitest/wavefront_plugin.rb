require_relative '../wavefront-sdk/write'

module Minitest
  def self.plugin_wavefront_init(options)
    # Minitest.reporter.reporters.clear
    Minitest.reporter << WavefrontReporter.new
  end
end

class WavefrontReporter < Minitest::StatisticsReporter
  attr_reader :wf
  BASE_PATH = 'dev.minitest.reporter'

  def initialize
    super
    setup_wavefront
  end

  # Credentials will be sourced from the environment. This could be
  # a ~/.wavefront file, or the WAVEFRONT_TOKEN and
  # WAVEFRONT_ENDPOINT environment variables.
  #
  def setup_wavefront
    raise unless ENV['WAVEFRONT_ENDPOINT']
    raise unless ENV['WAVEFRONT_TOKEN']

    @wf = Wavefront::Write.new({ endpoint: ENV['WAVEFRONT_ENDPOINT'],
                                 token:    ENV['WAVEFRONT_TOKEN'] },
                                writer: :api, verbose: true)
  rescue
    @wf = nil
    puts 'Wavefront reporter cannot be configured.'
  end

  def report
    return unless wf
    super
    WebMock.disable!
    p wf
    points = []
    ts = Time.now.utc.to_i
    tags = { passed: passed?.to_s }

    %w[total_time count assertions errors skips failures].each do |m|
      points.<<({ path:  format('%s.%s', BASE_PATH, m),
                  value: send(m.to_sym),
                  ts:    ts,
                  tags:  tags })
    end

    pp points

    wf.write(points)
  end

end
