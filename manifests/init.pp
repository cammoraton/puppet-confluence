# Class: confluence
#
# This module manages Atlassian Confluence (the enterprise wiki)
#
# Note that because Atlassian, in their infinite wisdom, does not
# supply a .deb / .rpm package(much less an .msi or .pkg), you must package
# confluence for yourself.  See the README for help with that.
#
# Parameters:
#   $version - The confluence version to install
#     version = 'installed' (Default)
#       Will NOT update confluence to the latest version
#     version = 'latest'
#       Will update to latest version
#     version = '3.0.2'
#       Will ensure v3.0.2 is installed
#   $package_source - where to get the package
#     package_source = 'apt' (Ubuntu/Debian default)
#       Install confluence package from supplied apt repository.
#       Requires $apt_X variables be set.  See using for details.
#     package_source = 'yum' (RedHat/Centos/Amazon default)
#       Install confluence package from supplied yum repository.
#       Not yet implemented.
#     package_source = 'file'
#       Install confluence from supplied file or source URL
#       Not yet implemented.
#     package_source = 'none'
#       Do not manage the package at all.
#   $enable_service
#     enable_service = true (Default)
#       Enable the confluence service
#     enable_service = false
#       Disable the confluence service
#   $service_name
#      The name of the service to manage defaults to 'confluence'
#   $ajp_port
#      tomcat AJP port, defaults to 8009
#   $shutdown_port
#      tomcat shutdown port, defaults to 8005
#   $http_port
#      Apache or tomcat http port.  Redirects to $https_port.
#      Defaults to 80(if $standalone is set will need to ensure
#      $confluence_user can start services on 80).
#   $https_port
#      Apache or tomcat https port.  Defaults to 443(if
#      $standalone is set will need to ensure $confluence_user
#      can start services on 443).
#   $user
#      User to run confluence as.  Defaults to 'confluence'
#   $uid
#      What UID the above $user should be.  Defaults to undefined.
#      which lets the underlying system pick.
#   $group
#      Group to run confluence as.  Defaults to 'confluence'
#   $gid
#      What GID the above $group should be.  Defaults to undefined
#      which lets the underlying system pick.
#   $base_dir
#     ( set from confluence::params )
#     Base directory for confluence.  Parent parameter for many other
#     directory parameters.  Must be fully qualified.
#
#     Defaults to '/usr/share/confluence'
#   $etc_dir
#     ( set from confluence::params )
#     Configuration directory for confluence.  Parent parameter for many
#     other parameters.  Must be fully qualified.
#
#     Defaults to '/etc/confluence'
#   $certs_dir
#     ( set from confluence::params )
#
#     Directory to store PEM certs for LDAPS ahead of keytool importation.
#     Must be fully qualified.
#
#     Defaults to '$base_dir/pki'
#   $webapps_dir
#     ( set from confluence::params )
#     Tomcat webapps directory.  Base location for Confluence WAR
#     Must be fully qualified.
#
#     Defaults to '$base_dir/webapps'
#   $log_dir
#     ( set from confluence::params )
#     Log directory.  Location where tomcat and confluence webapp should
#     drop logs.  Must be fully qualified.
#
#     Defaults to '$base_dir/logs'
#   $data_dir
#     ( set from confluence::params )
#     confluence.home.  The directory where confluence should store all it's
#     not database data(IE: attachements).  Must be fully qualified.
#
#     Defaults to '$base_dir/data'
#   $webapp
#     ( set from confluence::params )
#     The webapp context itself.  Defaults to 'ROOT' (the default context)
#   $webapp_dir
#     ( set from confluence::params )
#     Webapp directory. Must be fully qualified.
#
#     Defaults to '$webapps_dir/$webapp'
#   $webapp_conf
#     ( set from confluence::params )
#     Path to confluence configuration within exploded webapp.  Must be
#     fully qualified.
#
#     Defaults to '$webapp_dir/WEB-INF/classes'
#   $user_config
#     ( set from confluence::params )
#     Path to atlassian-user.xml.  Pre-confluence 4.0 this was how ldap
#     directories were managed.  Must be fully qualified.  Not currently used.
#
#     Defaults to '$webapp_conf/atlassian-user.xml'
#   $conluence_init
#     ( set from confluence::params )
#     Path to confluence-init.properties(which defines the location of
#     the data directory for confluence).  Must be fully qualified.
#
#     Defaults to '$webapp_conf/confluence-init.properties'
#   $server_xml
#     ( set from confluence::params )
#     Path to tomcat server.xml configuration.  Must be fully qualified.
#
#     Defaults to '$etc_dir/server.xml'
#   $confluence_conf
#     ( set from confluence::params )
#     Path to confluence configuration. Currently unused. Must be fully
#     qualified.
#
#     Defaults to '$data_dir/confluence.cfg.xml'
#   $symlink_app
#     ( set from confluence::params )
#     If set will symlink $webapp_dir to whatever this is set to. Must be
#     fully qualified. Currently unused.
#
#     Defaults to undefined.
#   $log_links
#     log_links = '/var/log/confluence'
#       Creates a symlink from $log_dir to /var/log/confluence owned
#       by $user:$log_group.  Must be an absolute path.
#     log_links = [ '/var/log/confluence', '/var/log/confluence2' ]
#       Creates symlinks from $log_dir to both /var/log/confluence
#       and /var/log/confluence2 owned by $user:$log_group.
#       All values in array must be absolute paths.
#   $etc_links
#     etc_links = '/usr/share/confluence/conf'
#       Creates a symlink from $etc_dir to /usr/share/confluence/conf
#       Ownership will be puppet default(generally 'root').  Must be
#       an absolute path.
#     etc_links = [ /etc/value1', '/etc/value2' ]
#       Creates symlinks from $etc_dir to /etc/value1 and /etc/value2.
#       Ownership will be puppet default(generally 'root').  All values
#       must be absolute paths.
#   $sysconfig
#     ( set from confluence::params )
#     Path to init arguments.
#
#     Defaults vary by distribution.
#     - Ubuntu/Debian = /etc/defaults/confluence
#     - RedHat = /etc/sysconfig/confluence
#   $min_heap
#     ( set from confluence::params )
#     Minimum heap size for the JVM that runs Tomcat.
#
#     Defaults to 256 MB.
#   $perm_space
#     ( set from confluence::params )
#     PermGen Size for the JVM that runs Tomcat.
#
#     Defaults to 256 MB.
#   $max_heap
#     ( set from confluence::params )
#     Maximum heap size for the JVM that runs Tomcat.
#
#     Defaults to half system memory or 512MB, whichever
#     is greater.
#   $log_group
#     ( set from confluence::params )
#     The group logging directories and log symlinks should
#     be set to.
#
#     Defaults vary by distribution:
#     - Ubuntu/Debian = 'adm'
#
#  Apache Parameters:
#   $standalone
#      standalone = false (Default)
#        Set up apache and put it in front of confluence
#      standalone = true
#        Skip setting up apache and just set up the coyote
#        connectors on $http_port / $https_port
#   $default_vhost
#      default_vhost = true (Default)
#        Confluence vhost will be default.  Also parameterizes
#        puppetlabs/apache class.
#      default_vhost = false
#        Does not set confluence as default vhost.  Will set
#        up as a name-based vhost on $servername.
#   $servername
#     ( set from confluence::params )
#     Servername to set on vhost.  Defaults to fqdn fact.
#   $vhost_name
#     Name of the apache::vhost resource for namespacing/namevar
#     defaults to 'confluence'
#
#  LDAPS Parameters:
#   $ldaps_server
#     If defined will add the specified server's ssl certificate
#     into the java truststore so that confluence may connect
#     over SSL without PKIK errors.
#
#     Will autoload the certificate by connecting to $ldaps_server
#     on $ldaps_port and retrieving the cert unless $ldaps_certificate
#     is defined.  Note that if this fails for whatever reason, it
#     will block other services.
#
#     Defaults to undefined.
#   $ldaps_certificate
#     A specific certificate in PEM format to load.  If set will
#     skip retrieving the certificate from $ldaps_server prior to
#     installation and just load this certificate.
#
#     Defaults to undefined.
#   $ldaps_port
#     Port to connect to ldap server on.  Defaults to 636(ldaps).
#   $truststore
#     Fully qualified path to java truststore to store certificate
#     in what so confluence can talk LDAPS without PKIK errors.
#     Defaults vary by distribution
#     - Ubuntu/Debian = $JAVA_HOME/jre/lib/security/cacerts
#   $truststore_pass
#     Password for the above $truststore.  Defaults to 'changeit'
#     (the java default).
#
#  Postgresql Parameters:
#   $local_database
#     local_database = true (Default)
#       Sets up a local postgresql database for confluence to
#       connect to using the $database_x fields
#     local_database = false
#       Skip setting up a local database - asssume it will be managed
#       off-server.
#   $database_name
#     Name of the database to set up/connect to.  Defaults to 'confluence'
#   $database_user
#     Username to setup/setup as owner of $database_name.
#     Defaults to 'confluence'
#   $database_password
#     The above $database_user's password.  Defaults to 'changeme'
#
#  Packaging (Apt) Parameters:
#   $apt_source_name
#     Name variable for all things apt repo.
#   $apt_location
#     URL for apt repository.  Not defined.
#   $apt_repo
#     Repository name.  Defaults to 'main'
#   $apt_manage_key
#     Whether or not to manage the key.  Defaults to false.
#   $apt_source
#     Source of the key
#   $apt_key
#     The key ID
#
# Sample Usage:
#
class confluence (
  $version              = 'installed',
  $enable_service       = true,
  $service_name         = 'confluence',
  $ajp_port             = '8009',
  $shutdown_port        = '8005',
  $http_port            = '80',
  $https_port           = '443',
  $user                 = 'confluence',
  $uid                  = undef,
  $group                = 'confluence',
  $gid                  = undef,
  $servername           = $confluence::params::servername,
  $base_dir             = $confluence::params::base_dir,
  $etc_dir              = $confluence::params::etc_dir,
  $certs_dir            = $confluence::params::certs_dir,
  $webapps_dir          = $confluence::params::webapps_dir,
  $log_dir              = $confluence::params::log_dir,
  $data_dir             = $confluence::params::data_dir,
  $webapp               = $confluence::params::webapp,
  $webapp_dir           = $confluence::params::webapp_dir,
  $webapp_conf          = $confluence::params::webapp_conf,
  $user_config          = $confluence::params::user_config,
  $confluence_init      = $confluence::params::confluence_init,
  $server_xml           = $confluence::params::server_xml,
  $confluence_conf      = $confluence::params::confluence_conf,
  $symlink_app          = $confluence::params::symlink_app,
  $sysconfig            = $confluence::params::sysconfig,
  $min_heap             = $confluence::params::min_heap,
  $perm_space           = $confluence::params::perm_space,
  $max_heap             = $confluence::params::max_heap,
  $log_group            = $confluence::params::log_group,
  $log_links            = undef,
  $etc_links            = undef,
  $standalone           = false,
  $default_vhost        = true,
  $vhost_name           = 'confluence',
  $ldaps_server         = undef,
  $ldaps_certificate    = undef,
  $ldaps_port           = '636',
  $truststore           = undef,
  $truststore_pass      = 'changeit',
  $local_database       = true,
  $database_name        = 'confluence',
  $database_user        = 'confluence',
  $database_password    = 'changeme',
  $package_source       = $confluence::params::package_source,
  $apt_source_name      = undef,
  $apt_location         = undef,
  $apt_repo             = 'main',
  $apt_manage_key       = false,
  $apt_source           = undef,
  $apt_key              = undef
) inherits confluence::params {
  # Bools must be booleans
  validate_bool($standalone)
  validate_bool($enable_service)
  validate_bool($local_database)
  validate_bool($default_vhost)
  validate_bool($apt_manage_key)

  # Version validation - needs improvement
  validate_re($version, 'present|installed|latest|^[.+_0-9a-zA-Z:-]+$')

  # Valid options for package source
  validate_re($package_source, 'apt|yum|file|none')

  # Ports should be digits
  validate_re($http_port,  '^[0-9]+$')
  validate_re($https_port, '^[0-9]+$')
  validate_re($ajp_port,   '^[0-9]+$')
  validate_re($ldaps_port, '^[0-9]+$')

  # Paths should be absolute
  validate_absolute_path($base_dir)
  validate_absolute_path($etc_dir)
  validate_absolute_path($certs_dir)
  validate_absolute_path($webapps_dir)
  validate_absolute_path($log_dir)
  validate_absolute_path($data_dir)
  validate_absolute_path($webapp_dir)
  validate_absolute_path($webapp_conf)
  validate_absolute_path($user_config)
  validate_absolute_path($confluence_init)
  validate_absolute_path($server_xml)
  validate_absolute_path($confluence_conf)
  unless ( $symlink_app == undef ) {
    validate_absolute_path($symlink_app)
  }
  unless ( $log_links == undef ) {
    if is_array($log_links) {
    } else {
      validate_absolute_path($log_links)
    }
  }
  unless ( $etc_links == undef ) {
    if is_array($etc_links) {
    } else {
      validate_absolute_path($etc_links)
    }
  }
  # Set up java
  include java

  class { 'confluence::package': } ->
  class { 'confluence::service':
    enable_service => $enable_service,
    subscribe      => Class['Java'],
  }

  # Package should do this, but is custom
  # so, just be sure user and group are made and right
  if ($gid == undef) {
    group { $group:
      ensure  => present,
      require => Class['Confluence::Package']
    }
  } else {
    group { $group:
      ensure  => present,
      gid     => $gid,
      require => Class['Confluence::Package']
    }
  }
  if ($uid == undef) {
    user { $user:
      ensure    => present,
      gid       => $group,
      require   => [
        Group[$group],
        Class['Confluence::Package'] ]
    }
  } else {
    user { $user:
      ensure    => present,
      uid       => $uid,
      gid       => $group,
      require   =>  [
        Group[$group],
        Class['Confluence::Package'] ]
    }
  }
  # Set up all our directories.
  # The package should do this, but since that's manual
  # go ahead and burn the resources on ensuring it.
  file { $base_dir:
    ensure  => directory,
    owner   => $user,
    group   => $group,
    require => [
      Class['Confluence::Package'],
      User[$user],
      Group[$group] ]
  }
  file { $etc_dir:
    ensure  => directory,
    owner   => $user,
    group   => $group,
    require => File[$base_dir]
  }
  file { $webapps_dir:
    ensure  => directory,
    owner   => $user,
    group   => $group,
    require => File[$base_dir]
  }
  file { $data_dir:
    ensure  => directory,
    owner   => $user,
    group   => $group,
    require => File[$base_dir]
  }
  file { $log_dir:
    ensure  => directory,
    owner   => $user,
    group   => $log_group,
    require => File[$base_dir]
  }

  # Configuration
  # Server.xml - tomcat config
  file { $server_xml:
    ensure  => present,
    owner   => $user,
    group   => $group,
    content => template('confluence/server.xml.erb'),
    require => File[$etc_dir],
    notify  => Class['Confluence::Service']
  }

  # Confluence init,
  # don't actually set up the webapp dir though
  file { $confluence_init:
    ensure  => present,
    owner   => $user,
    group   => $group,
    content => template('confluence/confluence-init.erb'),
    notify  => Class['Confluence::Service'],
    require => File[$data_dir]
  }

  # Sysconfig
  file { $sysconfig:
    ensure  => present,
    content => template('confluence/sysconfig.erb'),
    notify  => Class['Confluence::Service']
  }

  # Not yet implemented (still thinking through implications)
  # $confluence_conf
  # and
  # $user_conf

  # Symlinks
  unless ($symlink_app == undef ) {
    # Application link (if you like doing it that way)
    # being all things to all people.
    file { $webapp_dir:
      ensure  => $symlink_app,
      owner   => $user,
      group   => $group,
      require => File['$webapps_dir'],
      notify  => [
        Class['Confluence::Service'],
        File[$confluence_init] ]
    }
  }

  # Conveinance / layout links
  unless ( $log_links == undef ) {
    file { $log_links:
      ensure  => $log_dir,
      owner   => $user,
      group   => $log_group,
      require => File[$log_dir]
    }
  }
  unless ( $etc_links == undef ) {
    file { $etc_links:
      ensure  => $etc_dir,
      require => File[$etc_dir]
    }
  }

  # Major behavioral switches
  # Whether to set up apache or not.
  unless $standalone {
    class { 'confluence::apache':
      subscribe => Class['Confluence::Service']
    }
  }

  # Whether to set up postgresql or not.
  if $local_database {
    class { 'confluence::postgresql':
      notify => Class['Confluence::Service']
    }
  }

  # If we set an ldaps server...
  unless ( $ldaps_server == undef ) {
    # Truststore - I hate how I'm doing this
    if ( $truststore == undef ) {
      if $::osfamily == 'Debian' {
        $actual_truststore  = "${::java::java_home}/jre/lib/security/cacerts"
      } elsif $::osfamily == 'RedHat' {
        # TODO: fix this
        $actual_truststore  = undef
      } else {
        fail("Class['confluence']: Unsupported osfamily: ${::osfamily}")
      }
    } else {
      $actual_truststore = $truststore
    }

    # Create the cert-store (not really,
    # just a kludge to place pem certs somewhere to trigger
    # refreshes )
    file { $certs_dir:
      ensure          => directory,
      owner           => $user,
      group           => $user,
      require         => Class['Confluence::Package']
    }
    confluence::ldaps_server { $ldaps_server:
      ldaps_port      => $ldaps_port,
      truststore      => $actual_truststore,
      truststore_pass => $truststore_pass,
      certs_dir       => $certs_dir,
      certificate     => $ldaps_certificate,
      require         => File[$certs_dir]
    }
  }
}