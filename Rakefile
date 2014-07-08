require 'rubygems'
require 'puppetlabs_spec_helper/rake_tasks'

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