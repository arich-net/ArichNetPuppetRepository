# == Class: gerrit
#
# NTTEAM Gerrit manifests.
#
# === Parameters
#
# [*home*]
#   Specify Gerrit user home directory, /home/${user} by default.
#
# [*user*]
#   Specify the Gerrit user name, by default gerrit2.
#
# [*version*]
#   Specify the Gerrit version, by default 2.8.3.
#
# === Examples
#
#  class { gerrit:
#    user => 'gerrit',
#  }
#
# === Authors
#
# Alex Córcoles <alejandro.corcoles@ntt.eu>
# Rafael Durán Castañeda <rafael.duran@ntt.eu>
#
# === Copyright
#
# Copyright 2014 NTTEAM
#
class gerrit (
  $home    = undef,
  $user    = 'gerrit2',
  $version = '2.8.3',
){
  if !defined(Package['git']) {
    package { 'git': }
  }

  if !$home {
    $home_real = "/home/${user}"
  } else {
    $home_real = $home
  }

  Exec {
    user => $user,
  }

  File {
    owner => $user,
    group => $user,
  }

  user { $user:
    ensure     => present,
    home       => $home_real,
    managehome => true,
  }

  $url = "http://gerrit-releases.storage.googleapis.com/gerrit-${version}.war"
  $location = "${home_real}/gerrit-${version}.war"
  exec { "/usr/bin/curl ${url} -o ${location}":
    creates => $location,
  }

  $war = "${home_real}/gerrit.war"

  file { $war:
    ensure => link,
    target => $location,
  }

  $java = '/usr/bin/java'
  $site = "${home_real}/gerrit"
  $config = "${site}/etc/gerrit.config"
  $default_config = '/etc/default/gerritcodereview'

  exec { 'gerrit initialization':
    command => "${java} -jar ${war} init -d ${site} < /dev/null",
    creates => $config,
    require => File[$war],
  }

  file { $default_config:
    owner   => 'root',
    group   => 'root',
    content => template('gerrit/gerrit_default_config.erb'),
  }

  file { '/etc/init.d/gerrit':
    ensure  => link,
    owner   => 'root',
    group   => 'root',
    target  => "${site}/bin/gerrit.sh",
    require => Exec['gerrit initialization'],
  }

  service { 'gerrit':
    ensure    => running,
    enable    => true,
    hasstatus => false,
    pattern   => 'GerritCodeReview',
    require   => File['/etc/init.d/gerrit', $default_config],
  }

  firewall { '000 accept gerrit ssh connections':
    port   => 29418,
    proto  => 'tcp',
    action => 'accept',
  }
}
