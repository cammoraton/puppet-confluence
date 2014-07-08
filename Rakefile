require 'rubygems'
require 'puppet-lint/tasks/puppet-lint'
require 'puppetlabs_spec_helper/rake_tasks'

PuppetLint.configuration.ignore_paths = ["spec/**/*.pp"]

desc 'Set up gems and fixtures'
task :bootstrap do
  $stderr.puts "---> Running bundler"
  Rake::Task[:bundle].invoke
    
  $stderr.puts "---> Invoking spec_prep"
  Rake::Task[:spec_prep].invoke
end
 
desc "Install gems from Gemfile"
task :bundle do
  system 'bundle install'
end