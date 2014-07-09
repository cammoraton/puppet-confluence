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
  $vhost_name           = 'default',
  $http_port            = '80',
  $https_port           = '443',
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
  $truststore           = $confluence::params::default_truststore,
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
    }
  }

  # Should probably move this off into a defined type at some point
  if $ldaps {
    unless $ldaps_server {
      fail("Class['confluence']: Invalid ldaps_server: ${ldaps_server}")
    }
    file { $certs_dir:
      ensure       => directory,
      owner        => $user,
      group        => $group,
    } ->
    file { "${certs_dir}/${ldaps_server}.pem":
      ensure       => present,
      notify       => Exec['confluence::ldaps_cert::retrieve_cert'],
    }
    # Actual command is in the template
    exec { 'confluence::ldaps::retrieve_cert':
      command      => template('confluence/openssl_pem_retrieve.erb'),
      refreshonly  => true,
      notify       => Java_ks['confluence::ldaps::certificate'],
    }
    java_ks { 'confluence::ldaps::certificate':
      ensure       => latest,
      certificate  => "${certs_dir}/${ldaps_server}.pem",
      target       => $truststore,
      password     => $truststore_pass,
      trustcacerts => true,
      require      => File["${certs_dir}/${ldaps_server}.pem"],
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
