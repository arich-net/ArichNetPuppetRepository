# == Class: mng_servers::workers::celery_beat
#
class mng_server::workers::celery_beat {
  package {'ntteam-monitoring-ng-celery-beat': }
  $env = $mng_server::workers::env_real
  $wrapper = $mng_server::params::wrapper
  $pid = "--pidfile=${mng_server::workers::pids_dir}/beat.pid"

  supervisor::service { 'celery-beat':
    autorestart    => true,
    command        =>
    "celery -A ntteam.management beat --loglevel=INFO ${pid}",
    directory      => '/tmp',
    environment    => inline_template('<%= @env.join "," %>'),
    stderr_logfile => '/var/log/ntteam/celery/beat.log',
    stdout_logfile => '/var/log/ntteam/celery/beat.log',
    user           => $mng_server::workers::user,
    require        => Package['ntteam-monitoring-ng-celery-beat'],
    subscribe      => Concat[$wrapper],
  }
}
