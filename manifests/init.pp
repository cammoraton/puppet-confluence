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
  $standalone           = false,
  $http_port            = '80',
  $https_port           = '443',
  $redirect_to_https    = true,
  $ajp_port             = '8009',
  $servername           = $confluence::params::servername,
  $user                 = $confluence::params::user,
  $group                = $confluence::params::group,
  $ldaps                = false,
  $ldaps_server         = undef,
  $ldaps_port           = '636',
  $certs_dir            = $confluence::params::certs_dir,
  $truststore           = $confluence::params::default_truststore,
  $truststore_pass      = 'changeit',
) inherits confluence::params {
  validate_bool($standalone)
  validate_bool($enable_service)

  validate_re($version, 'present|installed|latest|^[.+_0-9a-zA-Z:-]+$')

  class { '::java':
    notify => Class['Confluence::Service'],
  }

  package { 'confluence':
    ensure => $confluence::version,
    notify => Class['Confluence::Service'],
  }

  class { 'confluence::service':
    enable_service => $enable_service,
  }

  if $standalone {

  } else {
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
}
