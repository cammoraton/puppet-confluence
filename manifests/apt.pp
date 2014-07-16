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
define confluence::apt (
  $source_name,
  $source_location,
  $source_repos,
  $source_release = $::lsbdistcodename,
  $manage_key     = false,
  $key_name       = undef,
  $key            = undef,
  $key_server     = undef
) {
  # Nearly never hurts to over test
  if $::osfamily != 'Debian' {
    fail('This module only works on Debian or derivatives like Ubuntu')
  }
  validate_bool($manage_key)

  # Suck in apt
  include ::apt

  # If we're managing the repo key, validate things
  if $manage_key {
    if $key_name == undef {
      fail('')
    }
    if $key == undef {
      fail('')
    }
    if $key_server == undef {
      fail('')
    }

    apt::key { $key_name:
      key        => $key,
      key_server => $key_server,
      notify     => Apt::Source[ $source_name ]
    }
  }
  apt::source { $source_name:
    location   => $source_location,
    release    => $source_release,
    repos      => $source_repos
  }
}