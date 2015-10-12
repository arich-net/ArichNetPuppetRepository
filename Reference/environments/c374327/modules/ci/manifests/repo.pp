# == Class: ci::repo
#
# NTTEAM CI service repositories management.
#
# === Authors
#
# Rafael Durán Castañeda <rafael.duran@ntt.eu>
#
# === Copyright
#
# Copyright 2014 NTTEAM
#
class ci::repo {
  case $::operatingsystem {
    /(?i)centos/ : {
      # Epel repo
      $url = 'http://ftp.cica.es/epel/6/x86_64/epel-release-6-8.noarch.rpm'
      package { 'epel-release':
        provider => 'rpm',
        source   => $url,
      }
    }
    /(?i)ubuntu/ : {
      # No extra repositories required
    }
    default: {
      fail 'Unsupported OS: we support just CentOS and Ubuntu'
    }
  }
}
