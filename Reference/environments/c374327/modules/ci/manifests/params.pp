# == Class: ci::params
#
# NTTEAM CI service params.
#
# === Authors
#
# Rafael Durán Castañeda <rafael.duran@ntt.eu>
#
# === Copyright
#
# Copyright 2014 NTTEAM
#
class ci::params {
  case $::operatingsystem {
    /(?i)centos/ : {
      $cgi = '/var/www/git/gitweb.cgi'
      $jenkins_config_hash = {'JENKINS_PORT' => { 'value' => '8118' }}
    }
    /(?i)ubuntu/ : {
      $cgi = '/usr/lib/cgi-bin/gitweb.cgi'
      $jenkins_config_hash = {'HTTP_PORT' => { 'value' => '8118' }}
    }
    default: {
      fail 'Unsupported OS: we support just CentOS and Ubuntu'
    }
  }
}
