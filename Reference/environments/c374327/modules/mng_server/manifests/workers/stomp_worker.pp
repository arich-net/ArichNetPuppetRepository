# == Class: mng_servers::workers::stomp_worker
#
class mng_server::workers::stomp_worker {
  package { 'ntteam-monitoring-ng-worker': }
  $env = $mng_server::workers::env_real
  $wrapper = $mng_server::params::wrapper

  supervisor::service { 'stomp-worker':
    autorestart    => true,
    command        => '/usr/bin/django-admin worker',
    directory      => '/tmp',
    environment    => inline_template('<%= @env.join "," %>'),
    stderr_logfile => '/var/log/ntteam/stomp-worker.log',
    stdout_logfile => '/var/log/ntteam/stomp-worker.log',
    user           => $mng_server::workers::user,
    require        => Package['ntteam-monitoring-ng-worker'],
    subscribe      => Concat[$wrapper],
  }
}
