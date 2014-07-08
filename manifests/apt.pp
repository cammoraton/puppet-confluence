# Class: confluence::apt
#
# This class manages the apt source for the confluence package
#
# Parameters:
#
# Actions:
#
# Requires:
#
# Sample Usage:
#
class confluence::apt (
) {
  # Nearly never hurts to over test
  if $::osfamily != 'Debian' {
    fail('This module only works on Debian or derivatives like Ubuntu')
  }

  include ::apt

  # Use ensure resource so other things may perhaps reference the apt repo
  ensure_resource('apt::source', '', {
    'ensure' => 'present' })
}