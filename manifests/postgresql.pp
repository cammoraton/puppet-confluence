# Class: confluence::postgresql
#
# This class wraps around and configures postgresql
#
# Parameters:
#
# Actions:
#
# Requires:
#
# Sample Usage:
#
class confluence::postgresql (
  $database_name     = $confluence::database_name,
  $database_user     = $confluence::database_user,
  $database_password = $confluence::database_password,
) {
  require postgresql::server

  postgresql::server::role { $database_user:
    password_hash => $database_password
  } ->
  postgresql::server::database { $database_name:
    owner         => $database_user
  }
}