require 'spec_helper'


describe 'confluence::apache', :type => :class do
  it { should contain_class("apache::service") }   
end