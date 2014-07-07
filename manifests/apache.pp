# Class: confluence::apache
#
# This class manages Apache front end and http to https redirect
#
# Parameters:
#
# Actions:
#
# Requires:
#
# Sample Usage:
#
class confluence::apache (
  
) {
  # Default apache vhost should redirect to ssl vhost.
  apache::listen { '80': }
  apache::vhost { 'default':
    default_vhost   => true,
    redirect_status => 'permanent',
    redirect_dest   => 'https://$servername'
  }
  apache::listen { '443': }
  class { 'apache::mod::ssl': }
  apache::vhost { 'default-ssl':
    port              => '443',
    default_ssl_vhost => true,
    proxy_pass        => [ { } ]
  }
}