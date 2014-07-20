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
  $default_vhost     = $confluence::default_vhost,
  $vhost_name        = $confluence::vhost_name,
  $http_port         = $confluence::http_port,
  $https_port        = $confluence::https_port,
  $ajp_port          = $confluence::ajp_port,
  $servername        = $confluence::servername
) {
  validate_bool($default_vhost)

  # This is kind of half-baked
  if $default_vhost {
    class { '::apache':
      default_vhost     => false,
      default_ssl_vhost => false
    }
  } else {
    include apache
  }

  include apache::mod::ssl
  apache::mod { 'proxy_ajp': }
  ensure_resource('apache::listen', $https_port, {})

  apache::vhost { $vhost_name:
    port            => $http_port,
    servername      => $servername,
    docroot         => $::apache::docroot,
    default_vhost   => $default_vhost,
    redirect_status => 'permanent',
    redirect_dest   => "https://${servername}",
  }

  apache::vhost { "${vhost_name}-ssl":
    port              => $https_port,
    servername        => $servername,
    default_vhost     => $default_vhost,
    ssl               => true,
    docroot           => $::apache::docroot,
    proxy_pass        => [ {
      'path' => '/',
      'url'  => "ajp://127.0.0.1:${ajp_port}/",
    } ],
  }
}