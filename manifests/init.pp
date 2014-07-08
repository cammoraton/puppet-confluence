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
  $version   = 'installed',
  $enable_service       = true,
  $service_name         = 'confluence',
  $ldaps                = false,
  $ldaps_cert           = undef,
  $standalone           = false,
  $servername           = $confluence::params::servername,
  $user                 = $confluence::params::user,
  $group                = $confluence::params::group,
) inherits confluence::params {
  validate_bool($standalone)
  validate_bool($enable_service)

  validate_re($version, 'present|installed|latest|^[.+_0-9a-zA-Z:-]+$')

  package { 'confluence':
    ensure => $confluence::version,
    notify => Class['Confluence::Service'],
  }

  class { 'confluence::service':
    enable_service => $enable_service,
  }

  if $standalone {

  } else {
    class { 'confluence::apache': }
  }
}
