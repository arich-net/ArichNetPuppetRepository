# == Class: mng_servers::workers::celery_worker
#
class mng_server::workers::celery_worker {
  package {'ntteam-monitoring-ng-celery-worker': }
  $env = $mng_server::workers::env_real
  $wrapper = $mng_server::params::wrapper
  $pid = "--pidfile=${mng_server::workers::pids_dir}/worker.pid"

  supervisor::service { 'celery-worker':
    autorestart    => true,
    command        =>
    "celery -A ntteam.management worker --loglevel=INFO ${pid}",
    directory      => '/tmp',
    environment    => inline_template('<%= @env.join "," %>'),
    stderr_logfile => '/var/log/ntteam/celery/worker.log',
    stdout_logfile => '/var/log/ntteam/celery/worker.log',
    user           => $mng_server::workers::user,
    require        => Package['ntteam-monitoring-ng-celery-worker'],
    subscribe      => Concat[$wrapper],
  }
}
