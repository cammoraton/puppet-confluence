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
  $ldaps_cert           = false,
  $ldaps_server         = undef,
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

  if $ldaps_cert {
    unless $ldaps_server {
      fail("")
    }
    
    java_ks { 'confluence::ldaps_cert': 
      certificate  => false,
      ensure       => latest,
      target       => $truststore,
      password     => $truststore_pass,
      trustcacerts => true,
    }
  }
}
