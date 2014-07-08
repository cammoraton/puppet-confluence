require 'spec_helper'

describe 'confluence', :type => :class do
  context "on an Ubuntu OS" do
    let :facts do
      {
         :osfamily               => 'Debian',
         :operatingsystemrelease => '14.04',
      }
    end
    it { should include_class("confluence::params") }
    it { should_not contain_class("confluence::apache") }

    it { should contain_class("confluence::service") }   
  end
end