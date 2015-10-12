# == Class: mng_server::workers
#
class mng_server::workers (
  $celery_beat = true,
  $celery_flower = true,
  $celery_worker = true,
  $env = undef,
  $flower_port = 5555,
  $groups = undef,
  $pids_dir = '/var/run/celery',
  $stomp_worker = true,
  $user = 'celery',
) {
  include 'cleng'
  contain 'mng_server::settings'

  $env_real = pick(
    $env,
    ["DJANGO_SETTINGS_MODULE='${mng_server::params::settings}'"]
  )

  class { 'supervisor':
    conf_dir => '/etc/supervisor/conf.d',
    conf_ext => '.conf',
  }

  group { $user:
    ensure => present,
  }

  user { $user:
    ensure  => present,
    gid     => $user,
    groups  => $groups,
    require => Group[$user],
  }

  file { $pids_dir:
    ensure => directory,
    owner  => $user,
  }

  file { '/etc/apt/preferences.d/99disable_python-librabbitmq':
    content => 'Package: python-librabbitmq
Pin: release *
Pin-Priority: -1',
  }

  $requires = [
    File[$pids_dir, '/etc/apt/preferences.d/99disable_python-librabbitmq'],
    User[$user]
  ]
  $subscribes = Exec['apt_update']

  if $celery_beat {
    class { 'mng_server::workers::celery_beat':
      subscribe => $subscribes,
      require   => $requires,
    }
  }

  if $celery_flower {
    class { 'mng_server::workers::celery_flower':
      subscribe => $subscribes,
      require   => $requires,
    }
  }

  if $celery_worker {
    class { 'mng_server::workers::celery_worker':
      subscribe => $subscribes,
      require   => $requires,
    }
  }

  if $stomp_worker {
    class { 'mng_server::workers::stomp_worker':
      subscribe => $subscribes,
      require   => $requires,
    }
  }
}
