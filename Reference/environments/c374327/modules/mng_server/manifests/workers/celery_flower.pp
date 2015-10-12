# == Class: mng_servers::workers::celery_flower
#
class mng_server::workers::celery_flower {
  package {'ntteam-monitoring-ng-celery-flower': }
  $env = $mng_server::workers::env_real
  $port = $mng_server::workers::flower_port
  $options= "--port=${port} --loglevel=INFO"
  $wrapper = $mng_server::params::wrapper

  firewall { '0020 accept celery-flower connections':
    port   => $port,
    proto  => 'tcp',
    action => 'accept',
  }

  supervisor::service { 'celery-flower':
    autorestart    => true,
    command        => "celery -A ntteam.management flower ${options}",
    directory      => '/tmp',
    environment    => inline_template('<%= @env.join "," %>'),
    stderr_logfile => '/var/log/ntteam/celery/flower.log',
    stdout_logfile => '/var/log/ntteam/celery/flower.log',
    user           => $mng_server::workers::user,
    require        => Package['ntteam-monitoring-ng-celery-flower'],
    subscribe      => Concat[$wrapper],
  }
}
