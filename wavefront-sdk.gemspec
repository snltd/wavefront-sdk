# frozen_string_literal: true

require 'pathname'
require 'date'
require_relative 'lib/wavefront-sdk/defs/version'

Gem::Specification.new do |gem|
  gem.name          = 'wavefront-sdk'
  gem.version       = WF_SDK_VERSION

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

  gem.add_dependency 'addressable', '~> 2.7'
  gem.add_dependency 'faraday', '~> 1.1'
  gem.add_dependency 'inifile', '~> 3.0'
  gem.add_dependency 'map', '~> 6.6'

  gem.add_development_dependency 'minitest', '~> 5.14'
  gem.add_development_dependency 'rake', '~> 13.0'
  gem.add_development_dependency 'rubocop', '~> 1.17'
  gem.add_development_dependency 'rubocop-minitest', '~> 0.10'
  gem.add_development_dependency 'rubocop-performance', '~> 1.3'
  gem.add_development_dependency 'rubocop-rake', '~> 0.5'
  gem.add_development_dependency 'simplecov', '~> 0.18'
  gem.add_development_dependency 'spy', '1.0.0'
  gem.add_development_dependency 'webmock', '~> 3.9'
  gem.add_development_dependency 'yard', '~> 0.9'

  gem.required_ruby_version = Gem::Requirement.new('>= 2.5.0')
end
