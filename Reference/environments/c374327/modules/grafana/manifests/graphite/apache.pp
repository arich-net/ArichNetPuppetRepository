# == Class: grafana::graphite::apache
#
# Manage Graphite Apache configuration.
#
# === Parameters
#
# [*graphite_root*]
#  Graphite web root, where
#
# [*graphite_vhost_group*]
#  Group for the Graphite Apache vhost, by default _graphite.
#
# [*graphite_vhost_user*]
#  User for the Graphite Apache vhost, by default _graphite.
#
# [*lib_dir*]
#  Directory where Graphite data files are placed, by default
# /var/lib/graphite.
#
# [*log_dir*]
#  Directory where graphite will be logging, by default /var/log/graphite.
#
# [*manage_host*]
#  Whether we should create an /etc/hosts entry for *vhost_name* or not,
#  false by default.
#
# [*port*]
#  Port Apache will be listening to, by default 80.
#
# [*src_root*]
#  Python source directory root, used in order to find Django admin media;
#  by default /usr/lib/python2.7/dist-packages.
#
# [*vhost_name*]
#   Graphite Aapache vhost name, by default _graphite.${::domain}_.
#
# [*wsgi_script*]
#  WSGI script import path, by default /usr/share/graphite-web/graphite.wsgi.
#
# === Examples
#
#  include 'grafan::graphite::apache'
#
# === Authors
#
# Rafael Durán Castañeda <rafael.duran@ntt.eu>
#
# === Copyright
#
# Copyright 2014 NTTEAM
#
class grafana::graphite::apache (
  $graphite_root = '/usr/share/graphite-web',
  $graphite_vhost_group = '_graphite',
  $graphite_vhost_user = '_graphite',
  $lib_dir = '/var/lib/graphite',
  $log_dir = '/var/log/graphite',
  $manage_host = false,
  $port = 80,
  $src_root = '/usr/lib/python2.7/dist-packages',
  $vhost_name = undef,
  $wsgi_script = undef,
) {
  include '::apache'
  include '::apache::mod::headers'

  $requires = Package['graphite-web']
  $vhost_name_real = pick($vhost_name, "graphite.${::domain}")
  $wsgi_script_real = pick($wsgi_script, "${graphite_root}/graphite.wsgi")

  if $manage_host {
    host { $vhost_name_real:
      ip => '127.0.0.1',
    }
  }

  # This is terrible hack for ensuring the right permissions for the log and
  # data files
  $files = [
    "${log_dir}/cache.log",
    "${log_dir}/exception.log",
    "${log_dir}/info.log",
    "${log_dir}/metricaccess.log",
    "${log_dir}/rendering.log",
    "${lib_dir}/graphite.db",
    "${lib_dir}/search_index",
  ]

  file { $files:
    ensure  => file,
    owner   => $graphite_vhost_user,
    group   => $::apache::group,
    notify  => Service[$::apache::params::service_name],
    require => $requires,
  }

  file { "${lib_dir}/whisper":
    ensure  => directory,
    owner   => $graphite_vhost_user,
    group   => $::apache::group,
    notify  => Service[$::apache::params::service_name],
    require => $requires,
  }
  ## end hack

  # Another nasty hack... Source code looks for build-index.sh script, however
  # current package includes it as an executable, so we make a symbolic link...
  file { "${graphite_root}/bin":
    ensure  => directory,
    require => $requires,
  }

  file { "${graphite_root}/bin/build-index.sh":
    ensure  => link,
    target  => '/usr/bin/graphite-build-search-index',
    require => $requires,
  }
  ## end hack

  $path = "${src_root}/django/contrib/admin/static/"
  $aliases = [{'alias' => '/static', 'path' => $path}]
  $locations = '
  <Location "/content/">
      SetHandler None
  </Location>

  <Location "/static/">
      SetHandler None
  </Location>
'

  apache::vhost { "${vhost_name_real}:${port}":
    aliases                     => $aliases,
    access_log_file             => 'graphite-web-access.log',
    access_log_format           => 'common',
    custom_fragment             => $locations,
    default_vhost               => false,
    docroot                     => '/var/www/html',
    error_log_file              => 'graphite-web-error.log',
    headers                     => [
      'set Access-Control-Allow-Origin "*"',
      'set Access-Control-Allow-Methods "GET, OPTIONS"',
      'set Access-Control-Allow-Headers "origin, authorization, accept"',
    ],
    port                        => $port,
    wsgi_script_aliases         => {'/' => $wsgi_script_real},
    wsgi_import_script          => $wsgi_script_real,
    wsgi_import_script_options  => {
      'process-group'     => '%{GLOBAL}',
      'application-group' => '%{GLOBAL}',
    },
    wsgi_process_group          => 'graphite',
    wsgi_daemon_process         => 'graphite',
    wsgi_daemon_process_options => {
      user  => $graphite_vhost_user,
      group => $graphite_vhost_group,
    },
    require                     => $requires,
  }
}
