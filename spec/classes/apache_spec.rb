require 'spec_helper'

describe 'confluence::apache', :type => :class do
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
    it { should contain_class("apache::service") }   
     
  end
end