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
  gem.require_paths = %w[lib]
  gem.bindir        = 'bin'

  gem.add_dependency 'addressable', '~> 2.8'
  gem.add_dependency 'faraday', '~> 2.7'
  gem.add_dependency 'inifile', '~> 3.0'
  gem.add_dependency 'map', '~> 6.6'

  gem.required_ruby_version = Gem::Requirement.new('>= 3.0')
  gem.metadata['rubygems_mfa_required'] = 'true'
end
