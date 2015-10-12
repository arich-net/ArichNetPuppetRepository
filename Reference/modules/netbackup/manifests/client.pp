# Class: netbackup::client
#
# This module manages our internal netbackup
#
# Parameters:
# netbackup_nbservers = array of Netbackup servers (shouldn't need to be passed)
# netbackup_add_routes = flag to add routes to the hosts dependin on the DC and network POD
#
# Actions:
# 1) Make exclude list param
# 2) auto include hosts.allow?
# 3) cleaner approach to adding host entries, use nexus data?
#
# Requires:
#
# Sample Usage:
#
# [Remember: No empty lines between comments and class definition]
class netbackup::client ($netbackup_nbservers = $netbackup::params::nbservers, $netbackup_add_routes = $netbackup::params::add_routes) inherits ::netbackup::params {
  include netbackup

  file { "/etc/puppet-tmpfiles/${netbackup::params::netbackup_client_pkg}":
    owner  => root,
    group  => root,
    mode   => 644,
    ensure => present,
    source => "puppet:///ext-packages/netbackup/${netbackup::params::netbackup_client_pkg}",
  }

  package { "netbackup":
    name     => "netbackup",
    ensure   => present,
    provider => "${netbackup::params::provider}",
    source   => "/etc/puppet-tmpfiles/${netbackup::params::netbackup_client_pkg}",
    require  => [File["/etc/puppet-tmpfiles/${netbackup::params::netbackup_client_pkg}"], Exec["rpmnodep"], Exec["debnodep"]],
  }

  exec { "rpmnodep":
    onlyif  => ["test -f /bin/rpm"],
    require => File["/etc/puppet-tmpfiles/${netbackup::params::netbackup_client_pkg}"],
    command => "rpm -ivh --nodeps /etc/puppet-tmpfiles/${netbackup::params::netbackup_client_pkg}",
  }

  exec { "debnodep":
    onlyif  => ["test -f /bin/dpkg"],
    require => File["/etc/puppet-tmpfiles/${netbackup::params::netbackup_client_pkg}"],
    command => "apt-get install --no-install-recommends /etc/puppet-tmpfiles/${netbackup::params::netbackup_client_pkg}",
  }

  file { "/usr/openv/netbackup/exclude_list":
    owner   => root,
    group   => root,
    mode    => 644,
    ensure  => present,
    content => template("netbackup/exclude_list.erb"),
    require => Package["netbackup"],
  }

  file { "/usr/openv/netbackup/bp.conf":
    owner   => root,
    group   => root,
    mode    => 644,
    ensure  => present,
    content => template("netbackup/bp.conf.erb"),
    require => Package["netbackup"],
  }

  exec { 'netbackup_init.d_update':
    require => Package["netbackup"],
    command => $::operatingsystem ? {
      /(?i)(debian|ubuntu)/ => "update-rc.d netbackup defaults",
      /(?i)(redhat|centos)/ => "chkconfig --add netbackup",
      default               => ''
    },
  }
  
  exec { 'vxpbx_exchanged_init.d_update':
    require => Package["netbackup"],
    command => $::operatingsystem ? {
      /(?i)(debian|ubuntu)/ => "update-rc.d vxpbx_exchanged defaults",
      /(?i)(redhat|centos)/ => "chkconfig --add vxpbx_exchanged",
      default               => ''
    },
  }
  
  service { "netbackup":
    ensure   => running,
    enable   => true,
    require  => Package["netbackup"],
    provider => init;
  }
  
  if netbackup_add_routes {
    include netbackup::routes
  }
}
