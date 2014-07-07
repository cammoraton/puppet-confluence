require 'rubygems'
require 'puppetlabs_spec_helper/rake_tasks'

desc 'Set up gems and vendor modules'
task :bootstrap do
  Rake::Task[:bundle].invoke
  Rake::Task[:spec_prep].invoke
  Rake::Task[:librarian].invoke
end
 
desc "Install gems from Gemfile"
task :bundle do
  $stderr.puts "---> Running bundler"
  system 'bundle install'
end
 
desc 'Update vendor modules with librarian-puppet'
task :librarian do
  $stderr.puts "---> Running librarian-puppet"
  system "librarian-puppet instal --path=spec/fixtures/modules"
end