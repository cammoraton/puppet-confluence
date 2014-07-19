# Defined Resource Type: confluence::apt
#
# Wraps around puppetlabs/apt apt::key and apt::source
# types to define an apt source for the confluence package
#
# Parameters:
#
#
# Sample Usage:
# Should not be used directly
define confluence::apt (
  $location,
  $repo,
  $release        = $::lsbdistcodename,
  $include_src    = false,
  $manage_key     = false,
  $key            = undef,
  $source         = undef
) {
  # Nearly never hurts to over test
  if $::osfamily != 'Debian' {
    fail('This module only works on Debian or derivatives like Ubuntu')
  }

  validate_bool($manage_key)
  validate_bool($include_src)

  # Suck in apt
  include ::apt

  # If we're managing the repo key, validate things
  if $manage_key {
    if $key == undef {
      fail('Define[\'confluence::apt\']: key undefined')
    }
    if $source == undef {
      fail('Define[\'confluence::apt\']: source undefined')
    }

    apt::key { $key:
      key_source => $source,
      notify     => Apt::Source[ $name ]
    }
  }
  apt::source { $name:
    location    => $location,
    release     => $release,
    repos       => $repo,
    include_src => $include_src
  }
}