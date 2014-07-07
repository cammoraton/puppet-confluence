require 'spec_helper'

describe 'confluence::params', :type => :class do
  it "Should not contain any resources" do
    subject.resources.size.should == 4
  end
end
