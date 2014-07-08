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
  $confluence_version   = 'installed',
  $service_enable       = true,
  $ldaps                = false,
  $ldaps_cert           = undef,
  $standalone           = false, # 
) inherits confluence::params {
  validate_bool($standalone)
  validate_bool($service_enable)
 
  package { 'confluence':
    ensure => $confluence::confluence_version,
    notify => Class['Confluence::Service'],
  }

  class { 'confluence::service':
    service_enable => $service_enable,
  }
  
}
