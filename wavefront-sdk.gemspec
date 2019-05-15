require 'pathname'
require 'date'
require_relative 'lib/wavefront-sdk/defs/version'

Gem::Specification.new do |gem|
  gem.name          = 'wavefront-sdk'
  gem.version       = WF_SDK_VERSION
  gem.date          = Date.today.to_s

  gem.summary       = 'SDK for Wavefront API v2'
  gem.description   = 'SDK for Wavefront (wavefront.com) API v2 '

  gem.authors       = ['Robert Fisher']
  gem.email         = 'rob@sysdef.xyz'
  gem.homepage      = 'https://github.com/snltd/wavefront-sdk'
  gem.license       = 'BSD-2-Clause'

  gem.files         = `git ls-files`.split($INPUT_RECORD_SEPARATOR)
  gem.test_files    = gem.files.grep(/^spec/)
  gem.require_paths = %w[lib]
  gem.bindir        = 'bin'

  gem.add_dependency 'addressable', '~> 2.4'
  gem.add_dependency 'faraday', '~> 0.15.4'
  gem.add_dependency 'inifile', '~> 3.0'
  gem.add_dependency 'map', '~> 6.6'

  gem.add_development_dependency 'minitest', '~> 5.11'
  gem.add_development_dependency 'rake', '~> 12.0'
  gem.add_development_dependency 'rubocop', '~> 0.54.0'
  gem.add_development_dependency 'simplecov', '~> 0.16.0'
  gem.add_development_dependency 'spy', '~> 0.4.0'
  gem.add_development_dependency 'webmock', '~> 3.0'
  gem.add_development_dependency 'yard', '~> 0.9.5'

  gem.required_ruby_version = Gem::Requirement.new('>= 2.3.0')
end
