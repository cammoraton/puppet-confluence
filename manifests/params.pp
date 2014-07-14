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
  $service_name  = 'confluence'
  $user          = 'confluence'
  $group         = 'confluence'
  $database_user = 'confluence'
  $database_name = 'confluence'

  if($::fqdn) {
    $servername = $::fqdn
  } else {
    $servername = $::hostname
  }
  $confluence_base_dir = '/usr/share/confluence'
  $confluence_etc_dir = "${confluence_base_dir}/conf"
  $certs_dir = "${confluence_base_dir}/pki"

  $server_xml_path = "${confluence_etc_dir}/server.xml"
  class { '::java':
    notify => Class['Confluence::Service'],
  }

  $default_truststore = "${::java::java_home}/jre/lib/security/cacerts"

  if $::osfamily == 'Debian' {
  } else {
    fail("Class['confluence::params']: Unsupported osfamily: ${::osfamily}")
  }
}