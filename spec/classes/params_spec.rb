require 'spec_helper'

describe 'confluence::params', :type => :class do
  context "on an Ubuntu or Debian OS" do
    let :facts do
      {
        :osfamily               => 'Debian',
        :operatingsystemrelease => '14.04',
      }
    end

    it "Should not contain any resources" do
      subject.resources.size.should == 4
    end
  end
end
