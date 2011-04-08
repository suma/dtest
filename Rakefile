require 'rubygems'
require 'bundler'
begin
  Bundler.setup(:default, :development)
rescue Bundler::BundlerError => e
  $stderr.puts e.message
  $stderr.puts "Run `bundle install` to install missing gems"
  exit e.status_code
end
require 'rake'

require 'jeweler'
Jeweler::Tasks.new do |gem|
  # gem is a Gem::Specification... see http://docs.rubygems.org/read/chapter/20 for more options
  gem.name = "dtest"
  gem.homepage = "http://github.com/suma/dtest"
  gem.license = "Apache License Version 2.0"
  gem.has_rdoc = false
  gem.summary = %Q{DTest is a testing tool to describe integrating test for distributed systems.}
  gem.description = %Q{}
  gem.email = "suma@users.sourceforge.jp"
  gem.authors = ["Shuzo Kashihara"]
  # Include your dependencies below. Runtime dependencies are required when using your gem,
  # and development dependencies are only needed for development (ie running rake tasks, tests, etc)
  gem.add_development_dependency 'rspec', '> 1.2.3'
  gem.require_paths = ["lib"]
  gem.extra_rdoc_files = []
end
Jeweler::RubygemsDotOrgTasks.new

require 'rspec/core'
require 'rspec/core/rake_task'
RSpec::Core::RakeTask.new(:spec) do |spec|
  spec.pattern = FileList['spec/**/*_spec.rb']
end

RSpec::Core::RakeTask.new(:rcov) do |spec|
  spec.pattern = 'spec/**/*_spec.rb'
  spec.rcov = true
end

task :default => :spec


