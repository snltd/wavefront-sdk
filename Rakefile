require "bundler/gem_tasks"
require "rspec/core/rake_task"
require 'yard'

RSpec::Core::RakeTask.new(:spec)

task :default => :spec

task :install  do
  sh 'gem build ./wavefront-client.gemspec'
  sh 'gem install wavefront-client-*.gem --no-rdoc --no-ri'
  sh 'rm wavefront-client-*.gem'
end

YARD::Rake::YardocTask.new do |t|
  t.files   = ['lib/**/*.rb']
end
