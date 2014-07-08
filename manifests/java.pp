# Class: confluence::java_ks
#
# This class manages java
#
# Parameters:
#
# Actions:
#
# Requires:
#
# Sample Usage:
#
class confluence::java {
  include ::java

  $default_truststore = "${::java::java_home}/jre/lib/security/cacerts"
}