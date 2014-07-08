require 'rubygems'
require 'puppet-lint/tasks/puppet-lint'
require 'puppetlabs_spec_helper/rake_tasks'
require 'ci/reporter/rake/rspec'

PuppetLint.configuration.ignore_paths = ["spec/**/*.pp"]

ENV['CI_REPORTS'] = 'reports'  

desc 'Set up gems and fixtures'
task :bootstrap do
  Rake::Task[:bundle].invoke
  Rake::Task[:spec_prep].invoke
end
 
desc "Install gems from Gemfile"
task :bundle do
  system 'bundle install'
end

# Default task - lint, validate, test
task :default => [:lint, :validate, :spec_standalone]