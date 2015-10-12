# == Class mng_server::graphite
#
class mng_server::graphite (
  $database_url = 'sqlite:////var/lib/graphite/graphite.db',
  $graphite_root = '/usr/share/graphite-web',
  $graphite_user = '_graphite',
) {
  include '::apache'
  include '::apache::mod::wsgi'
  include '::cleng'
  include '::postgresql::lib::python'
  include '::grafana::graphite::apache'

  package { 'python-dj-database-url':
    require => Exec['apt_update'],
  }

  file { "${graphite_root}/initial_data.json":
    source  => 'puppet:///modules/mng_server/graphite_initial_data.json',
    owner   => $graphite_user,
    group   => $::apache::group,
    notify  => Exec['Graphite syncdb'],
    require => Package['graphite-web'],
  }

  class { '::graphite':
    carbon_cache_enable     => true,
    carbon_config_file      => 'puppet:///modules/mng_server/carbon.conf',
    web_local_settings_file => 'mng_server/graphite_local_settings.py.erb',
    notify                  => Exec['Graphite syncdb'],
  }

  firewall { '0010 accept carbon-cache connections':
    port   => 2003,
    proto  => 'tcp',
    action => 'accept',
  }

  exec { 'Graphite syncdb':
    command     => '/usr/bin/django-admin syncdb --noinput',
    cwd         => $graphite_root,
    environment => 'DJANGO_SETTINGS_MODULE=graphite.settings',
    refreshonly => true,
    logoutput   => 'on_failure',
    user        => $graphite_user,
    require     => [
      Class['::postgresql::lib::python'],
      Package['python-dj-database-url', 'graphite-web'],
    ],
  }

  graphite::carbon::cache::storage { '00_default_1min_for_1year_5min_for_3year':
    pattern    => '.*',
    retentions => '60s:365d,300s:1095d',
    notify     => Service['carbon-cache'],
  }
}
