require 'rubygems'
require 'puppet-lint/tasks/puppet-lint'
require 'puppetlabs_spec_helper/rake_tasks'
require 'ci/reporter/rake/rspec'

# Lint configuration
PuppetLint.configuration.ignore_paths = ["spec/**/*.pp"]
# Autoloader errors every. time.
PuppetLint.configuration.send('disable_autoloader_layout')

# Reports directory for CI reporter
ENV['CI_REPORTS'] = 'reports'  

# Default task - lint, validate, test
task :default => [:lint, :validate, :spec]