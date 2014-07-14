# == Define Resource Type: confluence::ldaps_server
#
define confluence::ldaps_server (
  $truststore,
  $truststore_pass,
  $certs_dir,
  $ldaps_port = '636',
  $certificate = undef
) {
  if $certificate == undef {
    file { "${certs_dir}/${name}.pem":
      ensure       => present,
      notify       => Exec["confluence::ldaps_server::${name}::retrieve_cert"],
    }
    # Actual command is in the template
    exec { "confluence::ldaps_server::${name}::retrieve_cert":
      command      => template('confluence/openssl_pem_retrieve.erb'),
      refreshonly  => true,
      notify       => Java_ks["confluence::ldaps_server::${name}::certificate"],
    }
  } else {
    file { "${certs_dir}/${name}.pem":
      ensure       => present,
      content      => $certificate,
      notify       => Java_ks["confluence::ldaps_server::${name}::certificate"]
    }
  }
  java_ks { "confluence::ldaps_server::${name}::certificate":
    ensure       => latest,
    certificate  => "${certs_dir}/${name}.pem",
    target       => $truststore,
    password     => $truststore_pass,
    trustcacerts => true,
    require      => File["${certs_dir}/${name}.pem"],
    notify       => Class['confluence::service']
  }
}