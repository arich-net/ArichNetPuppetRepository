# == Class: ci
#
# NTTEAM CI service manifests.
#
# === Parameters
#
# [*enable_jenkins_auth*]
#   Specify whether we should enable authentication or not for Jenkins.
#
# [*gerrit_auth_method*]
#   Specify the Gerrit authentication method.
#
# [*gerrit_server_name*]
#   Specify the Apache configuration ServerName for Gerrit, undef by default.
#
# [*jenkins_slaves_source*]
#   Same as ci::jenkins *slaves_source*.
#
# [*jenkins_server_name*]
#   Specify the Apache configuration ServerName for Jenkins, undef by default.
#
# [*ldap_bind_password*]
#   Specify the LDAP bind password.
#
# [*ldap_host*]
#   Specify the LDAP host for the Gerrit service.
#
# [*relayhost*]
#   Postfix relayhost, default value is 213.229.188.140.
#
# === Examples
#
#  class { ci:
#    jenkins_plugins => ['git', 'git-client', 'chucknorris'],
#  }
#
# === Authors
#
# Rafael Durán Castañeda <rafael.duran@ntt.eu>
#
# === Copyright
#
# Copyright 2014 NTTEAM
#
class ci (
  $enable_jenkins_auth = undef,
  $gerrit_auth_method  = undef,
  $gerrit_server_name  = undef,
  $jenkins_config_hash = undef,
  $jenkins_plugins     = [],
  $jenkins_slaves_source = undef,
  $jenkins_server_name = undef,
  $jenkins_ssh_key     = undef,
  $jenkins_ssh_public  = undef,
  $ldap_bind_hashed_password = undef,
  $ldap_host           = undef,
  $ldap_bind_password  = undef,
  $manage_selinux      = false,
  $relayhost           = '213.229.188.140',
  $timezone            = 'Europe/Madrid',
){
  include '::ntp'
  include '::gerrit'
  include 'ci::repo'

  class { 'timezone':
    timezone => $timezone,
  }

  if !$ldap_bind_hashed_password {
    $ldap_bind_hashed_password_real = strip(
      base64('encode', $ldap_bind_password)
    )
  } else {
    $ldap_bind_hashed_password_real = $ldap_bind_hashed_password
  }

  if $manage_selinux {
    case $::osfamily {
      /(?i)RedHat/: {
        selboolean { 'httpd_can_network_relay':
          value => 'on',
        }
      }
      default: {
        # nothing to do
        }
    }
  }

  class { 'ci::gerrit':
    auth_method        => $gerrit_auth_method,
    server_name        => $gerrit_server_name,
    ldap_bind_password => $ldap_bind_password,
    ldap_host          => $ldap_host,
  }

  class { 'ci::jenkins':
    enable_auth               => $enable_jenkins_auth,
    ldap_bind_hashed_password => $ldap_bind_hashed_password_real,
    ldap_host                 => $ldap_host,
    jenkins_config_hash       => $jenkins_config_hash,
    plugins                   => $jenkins_plugins,
    slaves_source             => $jenkins_slaves_source,
    server_name               => $jenkins_server_name,
    ssh_key                   => $jenkins_ssh_key,
    ssh_public                => $jenkins_ssh_public,
  }

  package { 'postfix': }
  package { 'sendmail':
    ensure => absent,
  }

  service  { 'postfix':
    ensure => running,
    enable => true,
  }

  file_line { 'postfix relayhost':
    path => '/etc/postfix/main.cf',
    line => "relayhost = [${relayhost}]",
  }

  host { 'localhost':
    ip           => '127.0.0.1',
    host_aliases => ['gerrit', 'jenkins'],
  }

  firewall { '0001 accept HTTP connections':
    port   => 80,
    proto  => 'tcp',
    action => 'accept',
  }
}
