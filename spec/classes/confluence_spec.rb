require 'spec_helper'

describe 'confluence', :type => :class do
  context "on an Ubuntu OS" do
    let :facts do
      {
        :operatingsystem        => 'Ubuntu',
        :lsbdistcodename        => 'trusty',
        :osfamily               => 'Debian',
        :operatingsystemrelease => '14.04',
        :concat_basedir         => '/tmp',
      }
    end
    # Not understanding this test
    #it { should include_class("confluence::params") }
      
    it { should contain_package("confluence").with(
      'notify' => 'Class[Confluence::Service]')}
    it { should contain_class("java").with(
      'notify' => 'Class[Confluence::Service]') } 
      
    it { should contain_class("confluence::service") }

    it { should contain_class("confluence::apache") }
    it { should contain_class("apache::service") } 
  end
end