# Class: confluence::service
#
# This class manages the confluence service
#
# Parameters:
#
# Actions:
#
# Requires:
#
# Sample Usage:
#
class confluence::service (
  $service_enable = true,
) {
  validate_bool($service_enable)
  
  service { 'confluence':
    ensure => $service_enable,
    name   => $confluence::confluence_name,
    enable => $service_enable,
  }
}