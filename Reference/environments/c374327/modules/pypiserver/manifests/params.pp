# == Class pypiserver::params
#
# This class is meant to be called from pypiserver
# It sets variables according to platform
#
class pypiserver::params {
  case $::osfamily {
    'RedHat', 'Debian': {
      $package_name = 'pypiserver'
    }
    default: {
      fail("${::operatingsystem} not supported")
    }
  }
}
