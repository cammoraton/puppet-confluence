# Class: confluence::package
#
# This module manages the confluence package and sources for
# the confluence package.
#
# Parameters:
#   $version - The confluence version to install
#     version = 'installed' (Default)
#       Will NOT update confluence to the latest version
#     version = 'latest'
#       Will update to latest version
#     version = '3.0.2'
#       Will ensure v3.0.2 is installed
#   $package_source
#     package_source = 'apt' (Ubuntu/Debian default)
#       Install confluence package from supplied apt repository.
#       Requires $apt_X variables be set.  See parameters(apt)
#     package_source = 'yum' (RedHat/Centos/Amazon default)
#       Install confluence package from supplied yum repository.
#       Not yet implemented.
#     package_source = 'file'
#       Install confluence from supplied file or source URL
#       Not yet implemented.
#     package_source = 'none'
#       Do not manage the package at all.
#
#  Parameters (apt):
#   $apt_source_name
#   $apt_location
#   $apt_repo
#   $apt_source
#   $apt_manage_key
#   $apt_key
#
# Sample Usage:
# Not to be called directly
class confluence::package (
  $version         = $confluence::version,
  $package_source  = $confluence::package_source,
  $apt_source_name = $confluence::apt_source_name,
  $apt_location    = $confluence::apt_location,
  $apt_repo        = $confluence::apt_repo,
  $apt_source      = $confluence::apt_source,
  $apt_manage_key  = $confluence::apt_manage_key,
  $apt_key         = $confluence::apt_key
) {
  validate_re($version, 'present|installed|latest|^[.+_0-9a-zA-Z:-]+$')
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
      fail("Class['confluence::package']: bad package_type: ${package_source}")
    }
  }
}