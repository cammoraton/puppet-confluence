require 'rubygems'
require 'puppet-lint/tasks/puppet-lint'
require 'puppetlabs_spec_helper/rake_tasks'
require 'ci/reporter/rake/rspec'

PuppetLint.configuration.ignore_paths = ["spec/**/*.pp"]
# Autoloader errors every. time.
PuppetLint.configuration.send('disable_autoloader_layout')

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
task :default => [:lint, :validate, :spec]