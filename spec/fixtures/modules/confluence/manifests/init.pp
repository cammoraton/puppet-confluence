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
) inherits confluence::params {
  # Set up Apache
  class { 'confluence::apache': }
}
