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
  $service_name         = 'confluence',
  $ajp_port             = '8009',
  $shutdown_port        = '8005',
  $http_port            = '80',
  $https_port           = '443',
  $user                 = 'confluence',
  $group                = 'confluence',
  $confluence_base_dir  = $confluence::params::confluence_base_dir,
  $confluence_etc_dir   = $confluence::params::confluence_etc_dir,
  $server_xml_path      = $confluence::params::server_xml_path,
  $servername           = $confluence::params::servername,
  $certs_dir            = $confluence::params::certs_dir,
  $standalone           = false,
  $default_vhost        = true,
  $vhost_name           = 'confluence',
  $ldaps_server         = undef,
  $ldaps_certificate    = undef,
  $ldaps_port           = '636',
  $truststore           = undef,
  $truststore_pass      = 'changeit',
  $local_database       = true,
  $database_name        = 'confluence',
  $database_user        = 'confluence',
  $database_password    = 'changeme',
  $package_source       = $confluence::params::package_source,
  $apt_source_name      = undef,
  $apt_location         = undef,
  $apt_repo             = undef,
  $apt_source           = undef,
  $apt_manage_key       = true,
  $apt_key              = undef
) inherits confluence::params {
  # Bools must be booleans
  validate_bool($standalone)
  validate_bool($enable_service)
  validate_bool($local_database)
  validate_bool($default_vhost)
  validate_bool($apt_manage_key)

  # Version validation - needs improvement
  validate_re($version, 'present|installed|latest|^[.+_0-9a-zA-Z:-]+$')

  # Valid options for package source
  validate_re($package_source, 'apt|yum|file|none')

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

  # Set up java
  include java
  
  class { 'confluence::package': } ->
  class { 'confluence::service': 
    enable_service => $enable_service,
    subscribe      => Class['java'],
  }

#  group { $group: ensure => present } ->
#  user { $user:
#    ensure => present,
#    group  => $group
#  }

  file { $server_xml_path:
    ensure  => present,
    content => template('confluence/server.xml.erb'),
    notify  => Class['Confluence::Service'],
  }

  unless $standalone {
    class { 'confluence::apache': }
  }

  if $local_database {
    class { 'confluence::postgresql':
      notify => Class['Confluence::Service']
    }
  }

  # If we set an ldaps server...
  unless ( $ldaps_server == undef ) {
    # Truststore - I hate how I'm doing this
    if ( $truststore == undef ) {
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

    # Create the cert-store (not really,
    # just a kludge to place pem certs somewhere to trigger
    # refreshes )
    file { $certs_dir:
      ensure          => directory,
      owner           => $user,
      group           => $user,
      require         => Class['Confluence::Package']
    }
    confluence::ldaps_server { $ldaps_server:
      ldaps_port      => $ldaps_port,
      truststore      => $actual_truststore,
      truststore_pass => $truststore_pass,
      certs_dir       => $certs_dir,
      certificate     => $ldaps_certificate,
      require         => File[$certs_dir]
    }
  }
}