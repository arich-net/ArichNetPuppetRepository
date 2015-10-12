# == Class: na_mcollective
#
# MCollective management manifests for NTTEAM.
#
class na_mcollective (
  # roles
  $client = false,
  $middleware = false,
  $server = true,

  # core configuration
  $main_collective = undef,
  $collectives = undef,
  $core_libdir = '/opt/cleng/libexec/mcollective/',
  $site_libdir = '/opt/cleng/local/libexec/mcollective/',
  $classesfile = '/var/opt/lib/cleng-puppet/state/classes.txt',
  $confdir = '/etc/cleng/mcollective',

  # networking
  $middleware_admin_password = undef,
  $middleware_admin_user = undef,
  $middleware_hosts = undef,
  $middleware_password = undef,
  $middleware_port = undef,
  $middleware_ssl = undef,
  $middleware_ssl_port = undef,
  $middleware_user = undef,

  # server-specific
  $server_daemonize = undef,
  $server_logfile = '/var/log/cleng-mcollective/mcollective.log',
  $server_loglevel = undef,
  $securityprovider = 'none',

  # client-specific
  $client_logger_type = undef,
  $client_loglevel = undef,

  # packages
  $client_package = 'cleng-mcollective-client',
  $server_package = 'cleng-mcollective',
  $mco_manage_packages = false,
  $packages_ensure = undef,

  # servcices
  $service_name = 'cleng-mcollective',
) {
  case "${client}_${server}" {
    /true_true/: {
      $packages = [$client_package, $server_package]
      $service = $service_name
    }
    /true_false/: {
      $packages = [$client_package]
    }
    /false_true/: {
      $packages = [$server_package]
      $service = $service_name
    }
    default: {
      fail 'You should install at least the client or the server'
    }
  }

  include 'cleng'

  package { $packages:
    ensure  => $packages_ensure,
    require => Class['cleng'],
  }

  class { '::mcollective':
    # This is hardcoded for use
    manage_packages => $mco_manage_packages,

    # roles
    client     => $client,
    middleware => $middleware,
    server     => $server,

    # core configuration
    confdir          => $confdir,
    connector        => 'activemq',
    main_collective  => $main_collective,
    collectives      => $collectives,
    core_libdir      => $core_libdir,
    site_libdir      => $site_libdir,
    classesfile      => $classesfile,
    securityprovider => $securityprovider,

    # networking
    middleware_admin_password => $middleware_admin_password,
    middleware_admin_user     => $middleware_admin_user,
    middleware_hosts          => $middleware_hosts,
    middleware_password       => $middleware_password,
    middleware_port           => $middleware_port,
    middleware_ssl            => $middleware_ssl,
    middleware_ssl_port       => $middleware_ssl_port,
    middleware_user           => $middleware_user,

    # server-specific
    server_daemonize   => $server_daemonize,
    server_logfile     => $server_logfile,
    server_loglevel    => $server_loglevel,
    service_name       => $service_name,

    # client-specific
    client_logger_type => $client_logger_type,
    client_loglevel    => $client_loglevel,

    # meta-options
    require => Package[$packages],
  }

  if $service {
    Datacat['mcollective::server'] ~> Service[$service]
  }

  mcollective::plugin  { 'service':
    source => 'puppet:///modules/na_mcollective/plugins/service',
  }

  mcollective::plugin  { 'multirpc':
    source => 'puppet:///modules/na_mcollective/plugins/multirpc',
  }

  if $server {
    mcollective::server::setting { 'plugin.service.provider':
      value => 'puppet',
    }
  }

  mkdir_p($site_libdir)
  mkdir_p($core_libdir)
}
