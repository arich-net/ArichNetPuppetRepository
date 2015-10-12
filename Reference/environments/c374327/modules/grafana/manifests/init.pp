# == Class: grafana
#
# Full description of class grafana here.
#
# === Parameters
#
# [*dashboard_content*]
#   Grafana dashboard file contents as an string, undefined by default. You have
#   to define either one, this parameter or *dashboard_source*.
#
# [*dashboard_source*]
#   Grafana dashboard file source, undefined by default. You have
#   to define either one, this parameter or *dashboard_content*.
#
# [*docroot*]
#   Apache docroot for Grafana vhost, default is _/var/www/grafana_.
#
# [*donwload_url*]
#   Downloads base URL, default is
#   http://grafanarel.s3.amazonaws.com
#
# [*manage_host*]
#  Whether we should create an /etc/hosts entry for *vhost_name* or not,
#  false by default.
#
# [*graphite_url*]
#   Graphite URL where Grafana should connect to, by default
#   _graphite.${::domain}_.
#
# [*port*]
#   Port Apache will be listening to, by default 80.
#
# [*version*]
#   Grafana version to be installed, default is _1.5.2_.
#
# [*vhost_name*]
#   Grafana Aapache vhost name, by default _grafana.${::domain}_.
#
# === Examples
#
#  class { grafana:
#    version => '1.5.0',
#  }
#
# === Authors
#
# Rafael Durán Castañeda <rafael.duran@ntt.eu>
#
# === Copyright
#
# Copyright 2014 NTTEAM
#
class grafana (
  $dashboard_content = undef,
  $dashboard_source  = undef,
  $docroot           = '/var/www/grafana',
  $download_url      = 'http://grafanarel.s3.amazonaws.com',
  $graphite_url      = "http://graphite.${::domain}",
  $manage_host       = false,
  $port              = 80,
  $version           = '1.5.2',
  $vhost_name        = "grafana.${::domain}",
){
  include '::apache'

  if $dashboard_source {
    $dashboard_source_real = $dashboard_source
  } elsif $dashboard_content {
    $dashboard_content_real = $dashboard_content
  }

  File {
    owner => $::apache::params::user,
    group => $::apache::params::group,
  }

  if $manage_host {
    host { $vhost_name:
      ip => '127.0.0.1',
    }
  }

  file { $docroot:
    ensure  => directory,
    require => Class['::apache'],
  }

  package { 'curl': }

  $download_url_real = inline_template(
    '<%= @download_url %>/grafana-<%= @version %>.tar.gz'
  )
  $download = "/usr/bin/curl -L ${download_url_real}"
  $extract = "/bin/tar -xvz -C ${docroot}"


  exec { 'Download and extract Grafana source':
    command => "${download} | ${extract}",
    creates => "${docroot}/grafana-${version}",
    require => [File[$docroot], Package['curl']],
  }

  if($dashboard_source_real or $dashboard_content_real) {
    file { "${docroot}/grafana-${version}/app/dashboards/default.json":
      source  => $dashboard_source_real,
      content => $dashboard_content_real,
      notify  => Service[$::apache::params::service_name],
      require => Exec['Download and extract Grafana source'],
    }
  }

  file { "${docroot}/grafana-${version}/config.js":
    content => template('grafana/config.js.erb'),
    notify  => Service[$::apache::params::service_name],
    require => Exec['Download and extract Grafana source'],
  }

  apache::vhost { "${vhost_name}:${port}":
    default_vhost => false,
    docroot       => "${docroot}/grafana-${version}",
    port          => $port,
    require       => Exec['Download and extract Grafana source'],
  }
}
