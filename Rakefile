require 'bundler/gem_tasks'
require 'yard'
require 'rake/testtask'
require 'rubocop/rake_task'

task default: %i[rubocop test]

Rake::TestTask.new do |t|
  t.pattern = 'spec/**/*_spec.rb'
  t.warning = false
end

RuboCop::RakeTask.new(:rubocop) do |t|
  t.options = ['--display-cop-names']
end

YARD::Rake::YardocTask.new do |t|
  t.files = ['lib/wavefront-sdk/*rb']
end
