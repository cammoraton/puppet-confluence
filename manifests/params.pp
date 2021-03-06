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
  $base_dir    = '/usr/share/confluence'
  $etc_dir     = '/etc/confluence'
  $certs_dir   = "${base_dir}/pki"
  $webapps_dir = "${base_dir}/webapps"
  $log_dir     = "${base_dir}/logs"
  $data_dir    = "${base_dir}/data"
  $webapp      = 'ROOT'
  $webapp_dir  = "${webapps_dir}/${webapp}"
  $webapp_conf = "${webapp_dir}/WEB-INF/classes"

  $user_config     = "${webapp_conf}/atlassian-user.xml"
  $confluence_init = "${webapp_conf}/confluence-init.properties"
  $server_xml      = "${etc_dir}/server.xml"
  $confluence_conf = "${data_dir}/confluence.cfg.xml"

  $symlink_app = undef

  # Don't actually use these
  $log_links   = [ '/var/log/confluence', "${data_dir}/logs" ]
  $etc_links   = [ "${base_dir}/conf" ]

  $min_heap   = 256
  $perm_space = 256
  # seriously I have to do an implicit to_i
  # via an inline template?  WTF parser dudes!
  $memory = inline_template('<%= @memorysize_mb.to_i %>')

  if $memory <= 1024 {
    $max_heap   = 512
  } else {
    $max_heap   = $memory / 2
  }
  if $::osfamily == 'Debian' {
    $package_source   = 'apt'
    $sysconfig        = '/etc/default/confluence'
    $log_group        = 'adm'
  } elsif $::osfamily == 'RedHat' {
    #$ssl_certs_dir    = $::distrelease ? {
    #  '5'     => '/etc/pki/tls/certs',
    #  default => '/etc/ssl/certs',
    #}
    $package_source   = 'yum'
    $sysconfig        = '/etc/sysconfig/confluence'
  } else {
    fail("Class['confluence::params']: Unsupported osfamily: ${::osfamily}")
  }
}