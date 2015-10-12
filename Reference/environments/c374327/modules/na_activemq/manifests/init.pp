# == Class: na_activemq
#
class na_activemq(
  $activemq_config = 'na_activemq/activemq.xml.erb',
  $apache_mirror = 'http://archive.apache.org/dist',
  $group = 'activemq',
  $home = '/opt',
  $user = 'activemq',
  $version = '5.5.0',
) {
  #ActiveMQ requires Jave JRE = modules/java/manifests/init.pp
  if ! defined (Package['java']) {
    class { 'java': distribution => 'jre', version => 'installed' }
  }

  user { $user:
    ensure     => present,
    home       => "${home}/${user}",
    managehome => false,
    shell      => '/bin/false',
  }

  group { $group:
    ensure  => present,
    require => User[$user],
  }

  $repo = "${apache_mirror}/activemq/apache-activemq/${version}"
  $tarball = "apache-activemq-${version}-bin.tar.gz"
  exec { 'activemq_wget':
    command => "wget ${repo}/${tarball}",
    cwd     => '/usr/local/src/',
    creates => "/usr/local/src/apache-activemq-${version}-bin.tar.gz",
    path    => ['/bin', '/usr/bin'],
    require => [User[$user], Group[$group]],
  }

  $chown = "chown -R ${user}:${group} ${home}/apache-activemq-${version}"
  exec { 'activemq_untar':
    command => "tar xf /usr/local/src/${tarball} && ${chown}",
    cwd     => $home,
    creates => "${home}/apache-activemq-${version}",
    path    => ['/bin', '/usr/bin'],
    require => [User[$user], Group[$group], Exec['activemq_wget']],
  }

  file { "${home}/activemq":
    ensure  => "${home}/apache-activemq-${version}",
    require => Exec['activemq_untar'],
  }

  file { '/etc/activemq':
    ensure  => "${home}/activemq/conf",
    require => File["${home}/activemq"],
  }

  file { '/var/log/activemq':
    ensure  => "${home}/activemq/data",
    require => File["${home}/activemq"],
  }

  file { "${home}/activemq/bin/linux":
    ensure  => "${home}/activemq/bin/linux-x86-64",
    require => File["${home}/activemq"],
  }

  file { '/var/run/activemq':
    ensure  => directory,
    owner   => $user,
    group   => $group,
    mode    => '0755',
    require => [User[$user], Group[$group], File["${home}/activemq"]],
  }

  file { '/etc/init.d/activemq':
    ensure  => "${home}/activemq/bin/linux-x86-64/activemq",
    owner   => 'root',
    group   => 'root',
    mode    => '0755',
    require => File["${home}/activemq"],
  }

  file { "${home}/apache-activemq-${version}/bin/linux-x86-64/wrapper.conf":
    owner   => $user,
    group   => $group,
    mode    => '0644',
    content => template('na_activemq/wrapper.conf.erb'),
    require => File["${home}/activemq"],
  }

  file { '/etc/activemq/activemq.xml':
    owner   => $user,
    group   => $group,
    mode    => '0644',
    content => template($activemq_config),
    notify  => Service['activemq'],
    require => File['/etc/activemq'],
  }

  service { 'activemq':
    ensure     => running,
    enable     => true,
    require    => [User[$user], Group[$group], File["${home}/activemq"]],
    subscribe  => File['/etc/activemq/activemq.xml'],
  }

}
