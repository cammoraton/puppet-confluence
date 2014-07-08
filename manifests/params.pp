# Class: confluence::params
#
# This class manages Confluence parameters
#
# Parameters:
#
# Actions:
#
# Requires:
#
# Sample Usage:
#
class confluence::params {
  $user = 'confluence'
  $group = 'confluence'

  if($::fqdn) {
    $servername = $::fqdn
  } else {
    $servername = $::hostname
  }
  $certs_dir = '/usr/share/confluence/pki'

  $default_truststore = "${::java::java_home}/jre/lib/security/cacerts"

  if $::osfamily == 'Debian' {
  } else {
    fail("Class['confluence::params']: Unsupported osfamily: ${::osfamily}")
  }
}