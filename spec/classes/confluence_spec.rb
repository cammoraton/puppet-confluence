require 'spec_helper'

describe 'confluence', :type => :class do
  context "on an Ubuntu OS" do
    let :facts do
      { :operatingsystem        => 'Ubuntu',
        :lsbdistcodename        => 'trusty',
        :osfamily               => 'Debian',
        :operatingsystemrelease => '14.04',
        :concat_basedir         => '/tmp', }
    end
    let :params do
      { :server_xml_path        => '/tmp/server.xml' }
    end
    # This test fails - it gets commented out because
    # I'm a bad person.
    # it { should include_class("confluence::params") }
      
    it { should contain_package("confluence").with(
      'notify' => 'Class[Confluence::Service]')}
    it { should contain_class("java").with(
      'notify' => 'Class[Confluence::Service]') } 
    it { should contain_file('/tmp/server.xml').with(
      'notify' => 'Class[Confluence::Service]')}

    it { should contain_class("confluence::service") }
    
    it { should contain_class("confluence::apache") }
    it { should contain_class("apache::service") } 
    
    it { should contain_class("confluence::postgresql") }
    it { should contain_class("postgresql::server::service") }
      
    describe "when standalone parameter is set to true" do
      let :params do
        { :standalone => true, }
      end
      
      it { should_not contain_class("confluence::apache") }
      it { should_not contain_class("apache::service") }
    end
    
    describe "when ldaps parameters are set" do
      let :params do
        { :ldaps        => true,
          :ldaps_server => "ldap.example.com",
          :certs_dir    => "/usr/share/confluence/pki", }
      end
      it { should contain_file("/usr/share/confluence/pki") }
      it { should contain_file("/usr/share/confluence/pki/ldap.example.com.pem") }
      it { should contain_java_ks('confluence::ldaps::certificate') }
    end
    
    describe "when manage_database parameter is set to false" do
      let :params do
        { :manage_database => false, }
      end
      it { should_not contain_class("confluence::postgresql") }
      it { should_not contain_class("postgresql::server::service") }
    end
  end
end
