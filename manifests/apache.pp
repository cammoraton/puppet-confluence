# Class: confluence::apache
#
# This class wraps around and configures apache
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
  $http_port         = $confluence::http_port,
  $https_port        = $confluence::https_port,
  $redirect_to_https = $confluence::redirect_to_https,
  $ajp_port          = $confluence::ajp_port,
  $servername        = $confluence::servername,
) {
  #validate_bool($redirect_to_https)
  
  class { "::apache": default_vhost => false }
  if $https_port {
    class { '::apache::mod::ssl': }
    ensure_resource('apache::listen', "${https_port}", {})

    ::apache::vhost { 'default-ssl':
      port              => $https_port,
      default_vhost     => true,
      ssl               => true,
      docroot           => $::apache::docroot,
      proxy_pass        => [ { } ],
    }    
    if $redirect_to_https {
      ::apache::vhost { 'default':
        port            => $http_port,
        docroot         => $::apache::docroot,
        default_vhost   => true,
        redirect_status => 'permanent',
        redirect_dest   => "https://${servername}",
      }
    } else {
      ::apache::vhost { 'default':
        port            => $http_port,
        docroot         => $::apache::docroot,
        default_vhost   => true,
        proxy_pass      => [ { } ],
      }
    }
  } else {
    ::apache::vhost { 'default':
      port            => $http_port,
      docroot         => $::apache::docroot,
      default_vhost   => true,
      proxy_pass      => [ { } ],
    }
  }  
}