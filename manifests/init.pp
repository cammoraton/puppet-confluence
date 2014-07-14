# Class: confluence
#
# This module manages confluence
#
# Parameters: none
#
# Actions:
#
# Requires: see Modulefile
#
# Sample Usage:
#
class confluence (
  $version              = 'installed',
  $enable_service       = true,
  $service_name         = $confluence::params::service_name,
  $standalone           = false,
  $manage_apache        = true,
  $default_vhost        = true,
  $vhost_name           = 'def',
  $http_port            = '80',
  $https_port           = '443',
  $ssl_cert             = $confluence::params::default_ssl_cert,
  $ssl_key              = $confluence::params::default_ssl_key,
  $ssl_chain            = undef,
  $ssl_ca               = undef,
  $ssl_crl_path         = undef,
  $ssl_crl              = undef,
  $redirect_to_https    = true,
  $ajp_port             = '8009',
  $shutdown_port        = '8005',
  $user                 = $confluence::params::user,
  $group                = $confluence::params::group,
  $confluence_base_dir  = $confluence::params::confluence_base_dir,
  $confluence_etc_dir   = $confluence::params::confluence_etc_dir,
  $server_xml_path      = $confluence::params::server_xml_path,
  $servername           = $confluence::params::servername,
  $certs_dir            = $confluence::params::certs_dir,
  $ldaps                = false,
  $ldaps_server         = undef,
  $ldaps_port           = '636',
  $truststore           = undef,
  $truststore_pass      = 'changeit',
  $manage_database      = true,
  $database_name        = $confluence::params::database_name,
  $database_user        = $confluence::params::database_user,
  $database_password    = 'changeme',
) inherits confluence::params {
  # Bools must be booleans
  validate_bool($standalone)
  validate_bool($enable_service)
  validate_bool($redirect_to_https)
  validate_bool($ldaps)
  validate_bool($manage_database)
  validate_bool($manage_apache)

  # Version validation - needs improvement
  validate_re($version, 'present|installed|latest|^[.+_0-9a-zA-Z:-]+$')

  # Ports should be digits
  validate_re($http_port,  '^[0-9]+$')
  validate_re($https_port, '^[0-9]+$')
  validate_re($ajp_port,   '^[0-9]+$')
  validate_re($ldaps_port, '^[0-9]+$')

  # Paths should be absolute
  validate_absolute_path($confluence_base_dir)
  validate_absolute_path($confluence_etc_dir)
  validate_absolute_path($server_xml_path)
  validate_absolute_path($certs_dir)

#  group { $group: ensure => present } ->
#  user { $user:
#    ensure => present,
#    group  => $group
#  }

  # Set up java
  class { '::java':
    notify => Class['Confluence::Service'],
  }

  package { 'confluence':
    ensure => $confluence::version,
    notify => Class['Confluence::Service'],
  }

  file { $server_xml_path:
    ensure  => present,
    content => template('confluence/server.xml.erb'),
    require => Package['confluence'],
    notify  => Class['Confluence::Service'],
  }

  class { 'confluence::service':
    enable_service => $enable_service,
  }

  unless $standalone {
    class { 'confluence::apache':
      http_port         => $http_port,
      https_port        => $https_port,
      redirect_to_https => $redirect_to_https,
      ajp_port          => $ajp_port,
      servername        => $servername,
      ssl_cert          => $ssl_cert,
      ssl_key           => $ssl_key,
      ssl_chain         => $ssl_chain,
      ssl_ca            => $ssl_ca,
      ssl_crl_path      => $ssl_crl_path,
      ssl_crl           => $ssl_crl
    }
  }

  # Now a define!
  if $ldaps {
    if $ldaps_server == undef {
      fail('Class[\'confluence\']: Must define ldap server')
    }
    # Truststore - I hate how I'm doing this
    if $truststore == undef {
      if $::osfamily == 'Debian' {
        $actual_truststore  = "${::java::java_home}/jre/lib/security/cacerts"
      } elsif $::osfamily == 'RedHat' {
        # TODO: fix this
        $actual_truststore  = undef
      } else {
        fail("Class['confluence']: Unsupported osfamily: ${::osfamily}")
      }
    } else {
      $actual_truststore = $truststore
    }
    # Create the truststore if it doesn't exist (EXPERIMENTAL)
    file { $actual_truststore:
      ensure => present,
      notify => Exec['confluence::create_truststore']
    }
    exec { 'confluence::create_truststore':
      refreshonly     => true,
      command         => template("confluence/keytool_create.erb"),
      notify          => Confluence::Ldaps_server[$ldaps_server]
    }
    # Create the cert-store
    file { $certs_dir:
      ensure          => directory,
      owner           => $user,
      group           => $user
    }
    confluence::ldaps_server { $ldaps_server:
      ldaps_port      => $ldaps_port,
      truststore      => $actual_truststore,
      truststore_pass => $truststore_pass,
      certs_dir       => $certs_dir,
      require         => File[$certs_dir]
    }
  }

  if $manage_database {
    class { 'confluence::postgresql':
      database_name     => $database_name,
      database_user     => $database_user,
      database_password => $database_password,
    }
  }
}