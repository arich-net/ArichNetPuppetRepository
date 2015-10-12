# == Class: mng_server::riemann
#
class mng_server::riemann (
  $bind = '127.0.0.1',
  $django_host_ip = undef,
  $django_host = 'localhost',
  $graphite_host_ip = undef,
  $graphite_host = 'localhost',
  $manage_django_host = false,
  $manage_graphite_host = false,
) {
  file { '/etc/riemann.config':
    content => template('mng_server/riemann.config.erb'),
    notify  => Service['riemann'],
  }

  class { '::riemann':
    config_file => '/etc/riemann.config',
  }

  package { 'ruby-dev': }

  class {'::riemann::dash':
    require => Package['ruby-dev'],
  }

  if $manage_django_host {
    host { $django_host:
      ip => $django_host_ip,
    }
  }

  if $manage_graphite_host {
    host { $graphite_host:
      ip => $graphite_host_ip,
    }
  }

  firewall { '0030 riemann tcp':
    action => 'accept',
    port   => 5555,
    proto  => 'tcp',
  }

  firewall { '0030 riemann udp':
    action => 'accept',
    port   => 5555,
    proto  => 'udp',
  }

  firewall { '0031 riemann websocket':
    action => 'accept',
    port   => 5556,
    proto  => 'tcp',
  }
}
