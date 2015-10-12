# == Class: ci::projects::monitoring_ng
#
# NTTEAM CI service manifests for monitoring-ng project
#
# === Authors
#
# Rafael Durán Castañeda <rafael.duran@ntt.eu>
#
# === Copyright
#
# Copyright 2014 NTTEAM
#
class ci::projects::monitoring_ng {
  include 'postgresql::lib::devel'

  case $::operatingsystem {
    /(?i)centos/ : {
      class { 'devtools':
        manage_epel => false,
      }

      $gpg = 'http://springdale.math.ias.edu/data/puias/6/x86_64/os'
      $mirror = 'http://puias.math.ias.edu/data/puias/computational'
      # Provides python27 and python3 packages
      yumrepo { 'PUIAS_6_computational':
        descr      => 'PUIAS computational Base $releasever - $basearch',
        gpgcheck   => '1',
        gpgkey     => "${gpg}/RPM-GPG-KEY-puias",
        mirrorlist => "${mirror}/\$releasever/\$basearch/mirrorlist",
      }

      file { '/usr/local/sbin/pip':
        ensure  => link,
        target  => '/usr/bin/python-pip',
        require => Package['python-pip'],
      }

      $pip = File['/usr/local/sbin/pip']
      $epel = Package['epel-release']
      $packages = [
        'python-devel',
        'python27',
        'python27-devel',
      ]
      $requires = [Yumrepo['PUIAS_6_computational'], $epel]
      $sqlite = 'sqlite-devel'
    }
    /(?i)ubuntu/ : {
      package { 'build-essential': }
      # provides missing python versions
      include 'apt'
      apt::ppa { 'ppa:fkrull/deadsnakes': }

      $epel = undef
      $pip = Package['python-pip']
      $packages = [
        'python-dev',
        'python2.7',
        'python2.7-dev',
      ]
      $requires = Apt::Ppa['ppa:fkrull/deadsnakes']
      $sqlite = 'libsqlite0-dev'
    }
    default: {
      fail 'Unsupported OS: we support just CentOS and Ubuntu'
    }
  }

  package { ['python-virtualenv', 'sloccount', 'python-pip']:
    require => $epel,
  }

  package { 'tox':
    ensure   => latest,
    provider => 'pip',
    require  => $pip,
  }

  package { 'pip':
    ensure   => '1.4.1',
    provider => 'pip',
    require  => $pip,
  }

  package { $packages:
    require => $requires,
  }

  package { $sqlite: }

  file { '/var/lib/jenkins/.pip':
    ensure => directory,
  }

  file { '/var/lib/jenkins/.pip/cache':
    ensure => directory,
  }

  file { '/var/lib/jenkins/.pip/pip.conf':
    owner   => 'jenkins',
    group   => 'jenkins',
    content => inline_template('[global]
allow_unverified = django-admin-tools
allow_all_external = true
download_cache = ~/.pip/cache
'),
  }
}
