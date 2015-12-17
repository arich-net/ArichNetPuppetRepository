# == Class: mcollective::client::packages
#
# Installs an MCollective client
class mcollective::client::packages {
  include ::mcollective::params

  package { 'mcollective-client':
    ensure  => present,
    require => $mcollective::params::client_require,
  }
}
