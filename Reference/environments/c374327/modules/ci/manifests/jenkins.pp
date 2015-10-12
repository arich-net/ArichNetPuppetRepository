# == Class: ci::jenkins
#
# NTTEAM CI service manifests for Jenkins.
#
# === Parameters
#
# [*enable_auth*]
#   Specify whether we should enable authentication or not.
#
# [*ldap_bind_hashed_password*]
#   Specify the LDAP bind hashed password.
#
# [*ldap_host*]
#   Specify the LDAP host for the Gerrit service.
#
# [*plugins*]
#   Specify plugins to be installed.
#
# [*slaves_source*]
#   Specify Jenkins slaves source for the firewall rule. By default same
#   network will be used.
#
# [*server_name*]
#   Specify the Apache configuration ServerName. Default is
#   _jenkins.${::domain}_
#
# [*ssh_key*]
#   Specify the SSH key (required for being able to clone Gerrit repositories).
#
# [*ssh_public*]
#   Specify the SSH public key.
#
# === Authors
#
# Rafael Durán Castañeda <rafael.duran@ntt.eu>
#
# === Copyright
#
# Copyright 2014 NTTEAM
#
class ci::jenkins (
  $ldap_bind_hashed_password = undef,
  $ldap_host                 = undef,
  $enable_auth               = true,
  $jenkins_config_hash       = undef,
  $plugins                   = [],
  $slaves_source             = undef,
  $server_name               = undef,
  $ssh_key                   = undef,
  $ssh_public                = undef,
){
  include 'apache'
  include 'apache::mod::proxy'
  include 'apache::mod::proxy_http'

  include 'ci::params'

  if !$ssh_public {
    $ssh_public_real = template('ci/jenkins_id_rsa.pub')
  } else {
    $ssh_public_real = $ssh_public
  }

  if !$ssh_key {
    $ssh_key_real = template('ci/jenkins_id_rsa')
  } else {
    $ssh_key_real = $ssh_key
  }

  if !$server_name {
    $server_name_real = "jenkins.${::domain}"
  } else {
    $server_name_real = $server_name
  }

  apache::vhost { $server_name_real:
    docroot    => '/var/www',
    proxy_dest => 'http://localhost:8080',
    port       => 80,
  }

  class { '::jenkins':
    config_hash        => $jenkins_config_hash,
    configure_firewall => false,
  }

  file { '/var/lib/jenkins/.ssh':
    ensure  => directory,
    owner   => 'jenkins',
    group   => 'jenkins',
    require => Package['jenkins'],
  }

  file { '/var/lib/jenkins/.ssh/id_rsa':
    mode    => '0400',
    owner   => 'jenkins',
    group   => 'jenkins',
    content => $ssh_key_real,
  }

  file { '/var/lib/jenkins/.ssh/id_rsa.pub':
    owner   => 'jenkins',
    group   => 'jenkins',
    content => $ssh_public_real,
  }

  file { '/var/lib/jenkins/config.xml':
    content  => template('ci/jenkins.config.xml.erb'),
    group    => 'jenkins',
    mode     => '0644',
    owner    => 'jenkins',
    require  => Package['jenkins'],
    notify   => Service['jenkins'],
  }

  if $slaves_source {
    # Check it looks like a CIDR
    validate_re($slaves_source, '^(\d+\.){3}\d+\/\d+$')

    firewall { '0002 accept Gerrit slaves connections':
      proto  => 'tcp',
      action => 'accept',
      source => $slaves_source,
    }
  }

  jenkins::plugin { $plugins: }
}
