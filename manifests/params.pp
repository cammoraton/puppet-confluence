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

  if $::osfamily == 'Debian' {
    $ssl_cert = '/etc/ssl/certs/ssl-cert-snakeoil.pem'
    $ssl_key  = '/etc/ssl/private/ssl-cert-snakeoil.key'
    $ssl_certs_dir    = '/etc/ssl/certs'
    
    $default_truststore = "${::java::java_home}/jre/lib/security/cacerts"
  } elsif $::osfamily == 'RedHat' {
    $ssl_cert     = '/etc/pki/tls/certs/localhost.crt'
    $ssl_key      = '/etc/pki/tls/private/localhost.key'
    $ssl_certs_dir        = $distrelease ? {
      '5'     => '/etc/pki/tls/certs',
      default => '/etc/ssl/certs',
    }
    # TODO: fix this
    $default_truststore = undef
  } else {
    fail("Class['confluence::params']: Unsupported osfamily: ${::osfamily}")
  }
}