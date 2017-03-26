require 'pathname'
require 'date'

require_relative 'lib/wavefront-sdk/version'

#lib = Pathname.new(__FILE__).dirname.realpath + 'lib'
#$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)

Gem::Specification.new do |gem|
  gem.name          = 'wavefront-sdk'
  gem.version       = WF_SDK_VERSION
  gem.date          = Date.today.to_s

  gem.summary       = 'SDK for Wavefront API v2'
  gem.description   = 'SDK for Wavefront (wavefront.com) API v2 '

  gem.authors       = ['Robert Fisher']
  gem.email         = 'slackboy@gmail.com'
  gem.homepage      = 'https://github.com/snltd/wavefront-sdk'
  gem.license       = 'BSD-2-Clause'

  gem.files         = `git ls-files`.split($/)
  gem.executables   = gem.files.grep(%r{^bin/}) { |f| File.basename(f) }
  gem.test_files    = gem.files.grep(%r{^(test|gem|features)/})
  gem.require_paths = ['lib']

  gem.add_dependency('rest-client', ['>= 1.6.7', '< 1.8'])
  gem.add_development_dependency('bundler', ['~> 1.3'])
  gem.add_development_dependency('rake', ['~> 12.0'])
  gem.add_development_dependency('yard',  ['~> 0.9.5'])
  gem.add_development_dependency('rubocop',  ['~> 0.47.0'])

  gem.required_ruby_version = Gem::Requirement.new('>= 2.2.0')
end
