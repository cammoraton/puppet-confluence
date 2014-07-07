require 'rubygems'
require 'puppetlabs_spec_helper/rake_tasks'

desc 'Set up gems and vendor modules'
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
 
desc 'Install modules with librarian-puppet'
task :librarian do
  system "librarian-puppet instal --path=spec/fixtures/modules"
end