# == Class: ci::gerrit
#
# NTTEAM CI service manifests for Gerrit.
#
# === Parameters
#
# [*auth_method*]
#   Specify authentication value, default is HTTP_LDAP. Valid values are
#   HTTP_LDAP, HTTP and OpenID.
#
# [*ldap_bind_password*]
#   Specify the LDAP bind password.
#
# [*ldap_host*]
#   Specify the LDAP host for the Gerrit service.
#
# [*cgi*]
#   CGI path location.
#
# [*server_name*]
#   Specify the Apache configuration ServerName. Default is
#   _gerrit.${::domain}_
#
# === Authors
#
# Rafael Durán Castañeda <rafael.duran@ntt.eu>
#
# === Copyright
#
# Copyright 2014 NTTEAM
#
class ci::gerrit (
  $auth_method        = 'HTTP_LDAP',
  $cgi                = undef,
  $ldap_bind_password = undef,
  $ldap_host          = undef,
  $server_name        = undef,
){
  include 'apache'
  include 'apache::mod::ldap'
  include 'apache::mod::proxy'
  include 'apache::mod::proxy_http'

  include 'ci::params'

  case $auth_method {
    /HTTP/: {
      if !$ldap_bind_password {
        fail 'ldap_bind_password is required when auth_method is HTTP_LDAP'
      }
      if !$ldap_host {
        fail 'ldap_host is required when auth_method is HTTP_LDAP'
      }
      $custom_fragment = template('ci/gerrit_fragment.erb')
    }
    'OpenID': {
      $custom_fragment = undef
    }
    default: {
      fail "${auth_method} authentication method is not supported"
    }
  }

  if !$cgi {
    $cgi_real = $ci::params::cgi
  } else {
    $cgi_real = $cgi
  }

  if !$server_name {
    $server_name_real = "gerrit.${::domain}"
  } else {
    $server_name_real = $server_name
  }

  apache::vhost { $server_name_real:
    docroot         => '/var/www',
    proxy_dest      => 'http://localhost:8118',
    port            => 80,
    notify          => Service['gerrit'],
    custom_fragment => $custom_fragment,
  }

  package { 'gitweb': }

  file { '/home/gerrit2/gerrit/etc/gerrit.config':
    content  => template('ci/gerrit.config.erb'),
    group    => 'root',
    mode     => '0644',
    owner    => 'root',
    require  => Exec['gerrit initialization'],
    notify   => Service['gerrit'],
  }
}
