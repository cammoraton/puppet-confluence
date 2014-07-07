require 'rubygems'
require 'puppetlabs_spec_helper/module_spec_helper'

RSpec.configure do |config|
  config.filter_run_excluding :example_group => lambda { |metadata|
    metadata[:file_path].include?('fixtures')
  }
  config.expect_with :rspec do |c|
    c.syntax = [ :should ]
  end
end