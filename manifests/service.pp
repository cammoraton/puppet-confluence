# Class: confluence::service
#
# This class manages the confluence service
#
# Parameters:
#
# Sample Usage:
# Should not be used directly.
class confluence::service (
  $enable_service = true,
) {
  validate_bool($enable_service)

  service { 'confluence':
    ensure => $enable_service,
    name   => $confluence::service_name,
    enable => $enable_service,
  }
}