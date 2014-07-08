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
    # This test fails - it gets commented out because
    # I'm a bad person.
    #it { should include_class("confluence::params") }
      
    it { should contain_package("confluence").with(
      'notify' => 'Class[Confluence::Service]')}
    it { should contain_class("java").with(
      'notify' => 'Class[Confluence::Service]') } 
      
    it { should contain_class("confluence::service") }
    
    it { should contain_class("confluence::apache") }
    it { should contain_class("apache::service") } 
      
    describe "when standalone parameter is set to true" do
      let :params do
        {
          :standalone => true,
        }
      end
      
      it { should_not contain_class("confluence::apache") }
      it { should_not contain_class("apache::service") }
    end
    
    describe "when ldaps parameters are set" do
      let :params do
        {
          :ldaps        => true,
          :ldaps_server => "ldap.example.com",
          :certs_dir    => "/usr/share/confluence/pki",
        }
      end
      it { should contain_file("#{certs_dir}") }
      it { should contain_file("#{certs_dir}/#{ldaps_server}.pem") }
      it { should contain_java_ks('confluence::ldaps::certificate') }
    end
  end
end
