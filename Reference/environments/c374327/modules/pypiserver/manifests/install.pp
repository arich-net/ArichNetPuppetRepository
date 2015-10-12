# == Class pypiserver::install
#
class pypiserver::install {
  include 'python'

  package { $pypiserver::params::package_name:
    provider => 'pipx',
  }

  # we need at least 1.6, since EPEL version is not enough, just use pip
  package { 'passlib':
    provider => 'pipx',
  }

  firewall { '0010 Allow HTTP trafic (pypi server)':
    proto  => 'tcp',
    port   => 80,
    action => 'accept',
  }
}
