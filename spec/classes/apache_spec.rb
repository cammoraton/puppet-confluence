require 'spec_helper'

describe 'confluence::apache', :type => :class do
  context "on an Ubuntu OS" do
    let :facts do
      {
         :osfamily               => 'Debian',
         :operatingsystemrelease => '14.04',
      }
    end
    it { should contain_class("apache::service") }   
     
  end
end