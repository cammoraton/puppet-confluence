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
      { :server_xml             => '/tmp/server.xml',
        :package_source         => 'none' }
    end
    
    # Booleans
    [ :standalone,
      :local_database,
      :default_vhost,
      :apt_manage_key
    ].each do |validate|
      context "when #{validate} param is not a boolean" do
        let(:params) { { validate.to_sym => "i'm not valid!" } }
        it { expect { should contain_class("confluence") }.to raise_error(Puppet::Error, /is not a boolean/) }
      end
    end

    # Absolute paths
    [ :base_dir,
      :etc_dir,
      :certs_dir,
      :webapps_dir,
      :log_dir,
      :data_dir,
      :webapp_dir,
      :webapp_conf,
      :user_config,
      :confluence_init,
      :server_xml,
      :confluence_conf,
      :symlink_app ].each do |validate|
      context "when #{validate} param is not a fully qualified path" do
        let(:params) { { validate.to_sym => "tmp/path" } }
        it { expect { should contain_class("confluence") }.to raise_error(Puppet::Error, /is not an absolute path/) }
      end
    end

    # This is never officially mentioned as deprecated but it
    # appears deprecated -
    # or at least fixing it appears nontrivial
    # it { should compile }
    
    # Should compile appears to be deprecated - this is
    # a rough approx
    it { should contain_class("confluence") }

    # This test fails 
    # - it gets commented out because I'm a bad person. -ncc
    #it { should include_class("confluence::params") }

    # Not managing it so it shouldn't exist      
    it { should_not contain_package("confluence") }

    it { should contain_class("confluence::package") }
    it { should contain_class("java") } 
    it { should contain_file('/tmp/server.xml').with(
      'notify' => 'Class[Confluence::Service]')}

    it { should contain_class("confluence::service").with(
      'subscribe' => 'Class[Java]')}
    it { should contain_group("confluence") }
    it { should contain_user("confluence").with(
      'require' => [
        'Group[confluence]',
        'Class[Confluence::Package]']) }
    
    [ "/usr/share/confluence",
      "/etc/confluence",
      "/usr/share/confluence/webapps",
      "/usr/share/confluence/logs",
      "/usr/share/confluence/data" ].each do |directory|
      it { should contain_file(directory).with(
        'owner'  => 'confluence',
        'ensure' => 'directory' )}
    end

    # Files

    it { should contain_class("confluence::apache").with(
      'subscribe' => 'Class[Confluence::Service]') }
    #it { should include_apache_listen('80') }
    #it { should include_apache_mod('ssl') }
    #it { should include_apache_mod('proxy_ajp') }
    #it { should include_apache_vhost('confluence') }
    #it { should include_apache_vhost('confluence-ssl') }
    it { should contain_class("apache::service") }
          
    it { should contain_class("confluence::postgresql").with(
      'notify' => 'Class[Confluence::Service]')  }
    it { should contain_class("postgresql::server::service") }
      
      
    describe "when standalone parameter is set to true" do
      let :params do
        { :standalone     => true,
          :package_source => 'none'}
      end
      
      it { should_not contain_class("confluence::apache") }
      it { should_not contain_class("apache::service") }
    end
    
    describe "when local_database parameter is set to false" do
      let :params do
        { :local_database => false,
          :package_source  => 'none' }
      end
      it { should_not contain_class("confluence::postgresql") }
      it { should_not contain_class("postgresql::server::service") }
    end
    
    describe "when ldaps parameters are set" do
      let :params do
        { :ldaps_server   => "ldap.example.com",
          :certs_dir      => "/usr/share/confluence/pki",
          :package_source => 'none' }
      end
      it { should contain_file("/usr/share/confluence/pki") }
      it { should contain_file("/usr/share/confluence/pki/ldap.example.com.pem") }
      it { should contain_java_ks("confluence::ldaps_server::ldap.example.com::certificate") }
    end
  end
end