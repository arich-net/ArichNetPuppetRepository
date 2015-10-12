# == Class: ci::projects::automation
#
# NTTEAM CI service manifests for ntteam-automation project.
#
# === Authors
#
# Rafael Durán Castañeda <rafael.duran@ntt.eu>
#
# === Copyright
#
# Copyright 2014 NTTEAM
#
class ci::projects::automation {
  case $::operatingsystem {
    /(?i)centos/ : {
      $libxml = 'libxml2-devel'
      $rpm_build = 'rpm-build'
    }
    /(?i)ubuntu/ : {
      $libxml = 'libxml2-dev'
      $rpm_build = 'rpm'
    }
    default: {
      fail "Unsupported OS: ${::operatingsystem}"
    }
  }

  if !defined(Package[$libxml]) {
    package { $libxml: }
  }

  if !defined(Package[$rpm_build]) {
    package { $rpm_build: }
  }
}
