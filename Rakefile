#require "bundler/gem_tasks"
#require "rspec/core/rake_task"
#require 'yard'
require 'rake/testtask'

#RSpec::Core::RakeTask.new(:spec)

#task :default => :spec
#
Rake::TestTask.new do |t|
  t.pattern = "spec/*_spec.rb"
end

task :install  do
  sh 'gem build ./wavefront-client.gemspec'
  sh 'gem install wavefront-client-*.gem --no-rdoc --no-ri'
  sh 'rm wavefront-client-*.gem'
end

#YARD::Rake::YardocTask.new do |t|
  #t.files   = ['lib/**/*.rb']
#end
