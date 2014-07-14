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
  $manage_apache     = $confluence::manage_apache,
  $default_vhost     = $confluence::default_vhost,
  $vhost_name        = $confluence::vhost_name,
  $http_port         = $confluence::http_port,
  $https_port        = $confluence::https_port,
  $redirect_to_https = $confluence::redirect_to_https,
  $ajp_port          = $confluence::ajp_port,
  $servername        = $confluence::servername,
  $ssl_cert          = $confluence::default_ssl_cert,
  $ssl_key           = $confluence::default_ssl_key,
  $ssl_chain         = $confluence::ssl_chain,
  $ssl_ca            = $confluence::ssl_ca,
  $ssl_crl_path      = $confluence::ssl_crl_path,
  $ssl_crl           = $confluence::ssl_crl
) {
  validate_bool($manage_apache)
  validate_bool($default_vhost)
  validate_bool($redirect_to_https)

  # This is kind of half-baked
  if $manage_apache {
    class { '::apache':
      default_vhost     => false,
      default_ssl_vhost => false }
  }
  if $https_port {
    class { '::apache::mod::ssl': }
    apache_mod { 'proxy_ajp': }
    ensure_resource('apache::listen', $https_port, {})

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
    if $redirect_to_https {
      apache::vhost { $vhost_name:
        port            => $http_port,
        servername      => $servername,
        docroot         => $::apache::docroot,
        default_vhost   => $default_vhost,
        redirect_status => 'permanent',
        redirect_dest   => "https://${servername}",
      }
    } else {
      apache::vhost { $vhost_name:
        port            => $http_port,
        servername      => $servername,
        docroot         => $::apache::docroot,
        default_vhost   => $default_vhost,
        proxy_pass      => [ {
          'path' => '/',
          'url'  => "ajp://127.0.0.1:${ajp_port}/",
        } ],
      }
    }
  } else {
    apache::vhost { $vhost_name:
      port            => $http_port,
      servername      => $servername,
      docroot         => $::apache::docroot,
      default_vhost   => $default_vhost,
      proxy_pass      => [ {
        'path' => '/',
        'url'  => "ajp://127.0.0.1:${ajp_port}/",
      } ],
    }
  }
}