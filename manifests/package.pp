# Class: confluence::package
#
# This module manages confluence package
#
# Parameters: none
#
# Actions:
#
# Requires: see Modulefile
#
# Sample
class confluence::package ( 
  $version        = $confluence::version,
  $package_source = $confluence::package_source 
) {
  validate_re($package_source, 'apt|yum|file|none')
  
  case $package_source {
    'apt': {
      if $::osfamily != 'Debian' {
        fail('Apt only supported on Debian or derivatives like Ubuntu')
      }
      if $apt_source_name == undef {
        fail('Class[\'confluence::package\']: apt_source_name undefined')
      }
      if $apt_repo == undef {
        fail('Class[\'confluence::package\']: apt_source_repos undefined')
      }
      if $apt_location == undef {
        fail('Class[\'confluence::package\']: apt_source_location undefined')
      }
      confluence::apt { $apt_source_name:
        location        => $apt_location,
        repo            => $apt_repo,
        source          => $apt_source,
        manage_key      => $apt_manage_key,
        key             => $apt_key
      } ->
      package { 'confluence': ensure => $version}
    }
    'yum': {
      fail('Class[\'confluence::package\']: Yum not yet supported')
    }
    'file': {
      fail('Class[\'confluence::package\']: File not yet supported')
    }
    'none': {
      notice('Class[\'confluence::package\']: Not managing package source')
    }
    default: {
      fail("Class['confluence::package']: Unrecognized package type ${package_source}")
    }
  }
}