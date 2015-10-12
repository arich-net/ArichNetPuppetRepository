# == Class: na_mcollective::puppetlabs
#
# MCollective management manifests for NTTEAM based on Puppetlabs packages for
# Ubuntu trusty.
#
class na_mcollective::puppetlabs (
  $middleware_hosts = [],
) {
  if "${::operatingsystem}_${::operatingsystemrelease}" != 'Ubuntu_14.04' {
    fail 'Only Ubuntu 14.04 is supported'
  }

  apt::source { 'puppetlabs':
    location   => 'http://apt.puppetlabs.com',
    repos      => 'main dependencies',
    key        => '4BD6EC30',
    key_server => 'pgp.mit.edu',
  }

  class { 'na_mcollective':
    client               => true,
    core_libdir          => '/usr/share/mcollective/plugins',
    site_libdir          => '/usr/local/share/mcollective',
    classesfile          => '/var/lib/puppet/state/classes.txt',
    confdir              => '/etc/mcollective',
    server_logfile       => '/var/log/mcollective.log',
    service_name         => 'mcollective',
    mco_manage_packages  => true,
    packages_ensure      => absent,
    middleware_hosts     => $middleware_hosts,
    require              => Exec['apt_update'],
  }
}
