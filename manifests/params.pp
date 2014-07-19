# Class: confluence::params
#
# This class sets up default parameters for the confluence class
# that require some kind of logic to set.
#
# IE: setting default value for package source based on
# operating system family fact.
#
# Parameters:
# None
#
# Sample Usage:
# Not to be used directly
class confluence::params {
  if($::fqdn) {
    $servername = $::fqdn
  } else {
    $servername = $::hostname
  }
  $confluence_base_dir = '/usr/share/confluence'
  $confluence_etc_dir = "${confluence_base_dir}/conf"
  $certs_dir = "${confluence_base_dir}/pki"

  $server_xml_path = "${confluence_etc_dir}/server.xml"

  if $::osfamily == 'Debian' {
    $ssl_cert         = '/etc/ssl/certs/ssl-cert-snakeoil.pem'
    $ssl_key          = '/etc/ssl/private/ssl-cert-snakeoil.key'
    $ssl_certs_dir    = '/etc/ssl/certs'
    $package_source   = 'apt'
  } elsif $::osfamily == 'RedHat' {
    $ssl_cert         = '/etc/pki/tls/certs/localhost.crt'
    $ssl_key          = '/etc/pki/tls/private/localhost.key'
    $ssl_certs_dir    = $::distrelease ? {
      '5'     => '/etc/pki/tls/certs',
      default => '/etc/ssl/certs',
    }
    $package_source   = 'yum'
  } else {
    fail("Class['confluence::params']: Unsupported osfamily: ${::osfamily}")
  }
}