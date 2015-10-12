# == Class: mng_server
#
class mng_server (
  $allowed_hosts = undef,
  $fixtures = {},
  $fixtures_dir = '/var/lib/ntteam_fixtures',
  $ipaddress = '127.0.0.1',
  $manage_host = false,
  $ntteam_root = '/usr/share/ntteam',
  $server_name = undef,
  $src_root = '/usr/lib/python2.7/dist-packages',
){
  include '::apache'
  include '::apache::mod::wsgi'
  include '::cleng'
  contain 'mng_server::settings'
  $wrapper = $mng_server::params::wrapper
  Concat[$wrapper] ~> Service['httpd']

  $server_name_real = pick($server_name, "mng.${::domain}")
  $allowed_hosts_real = pick($allowed_hosts, $server_name_real)

  mng_server::setting { 'ALLOWED_HOSTS':
    value => $allowed_hosts_real,
  }

  package { 'ntteam-monitoring-ng':
    require => Exec['apt_update'],
    notify  => Exec['monitoring-ng syncdb']
  }

  file { $fixtures_dir:
    ensure => directory,
  }

  $fixture = "${fixtures_dir}/initial_data.yaml"
  concat { $fixture:
    owner   => 'root',
    group   => 'root',
    mode    => '0644',
    notify  => Exec['monitoring-ng syncdb'],
  }

  concat::fragment { 'package initial_data.yaml':
    target  => $fixture,
    source  => 'file:///usr/share/ntteam/initial_data.yaml',
    order   => '01',
    require => Package['ntteam-monitoring-ng'],
  }

  $defaults = {
    target => $fixture,
    order  => '02',
  }
  create_resources(concat::fragment, $fixtures, $defaults)

  firewall { '0010 accept HTTP connections':
    port   => 80,
    proto  => 'tcp',
    action => 'accept',
  }

  exec { 'monitoring-ng syncdb':
    command     => "${wrapper} /usr/bin/django-admin syncdb --noinput",
    cwd         => $fixtures_dir,
    logoutput   => 'on_failure',
    refreshonly => true,
    notify      => Service['httpd'],
    subscribe   => Concat[$wrapper],
  }

  # Some hacks ensuring SQLite databases work
  if $mng_server::params::database_url =~ /^sqlite:\/\/\/(.*)/ {
    $directory = dirname($1)
    file { $directory:
      ensure    => directory,
      owner     => $::apache::user,
      group     => $::apache::group,
      mode      => '0775',
      subscribe => Exec['monitoring-ng syncdb'],
    }

    file { $1:
      owner     => $::apache::user,
      group     => $::apache::group,
      subscribe => Exec['monitoring-ng syncdb'],
    }
  }

  # TODO (rafaduran): metrics sync

  if $manage_host {
    host { $server_name_real:
      ip => $ipaddress,
    }
  }

  $wsgi_script = "${src_root}/ntteam/management/wsgi.py"

  apache::vhost { $server_name_real:
    aliases                    => [
      {
        alias => '/static',
        path  => "${ntteam_root}/static/",
      },
    ],
    docroot                    => '/var/www/html',
    port                       => 80,
    wsgi_script_aliases        => {'/' => $wsgi_script},
    wsgi_import_script         => $wsgi_script,
    wsgi_import_script_options => {
      'process-group'     => '%{GLOBAL}',
      'application-group' => '%{GLOBAL}',
    },
    require                    => Package['ntteam-monitoring-ng'],
  }
}
