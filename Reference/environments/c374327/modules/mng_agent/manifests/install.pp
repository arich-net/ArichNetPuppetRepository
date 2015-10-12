# == Class mng_agent::install
#
class mng_agent::install {
  class { 'na_mcollective':
    # roles
    client => $mng_agent::mco_client,
    server => $mng_agent::mco_server,

    # core configuration
    main_collective => $mng_agent::mco_main_collective,
    collectives     => $mng_agent::mco_collectives,

    # middleware options
    middleware_admin_password => $mng_agent::mco_middleware_admin_password,
    middleware_admin_user     => $mng_agent::mco_middleware_admin_user,
    middleware_hosts          => $mng_agent::mco_middleware_hosts,
    middleware_password       => $mng_agent::mco_middleware_password,
    middleware_port           => $mng_agent::mco_middleware_port,
    middleware_ssl            => $mng_agent::mco_middleware_ssl,
    middleware_ssl_port       => $mng_agent::mco_middleware_ssl_port,
    middleware_user           => $mng_agent::mco_middleware_user,

    # server-specific
    server_daemonize   => $mng_agent::mco_server_daemonize,
    server_logfile     => $mng_agent::mco_server_logfile,
    server_loglevel    => $mng_agent::mco_server_loglevel,

    # client-specific
    client_logger_type => $mng_agent::mco_client_logger_type,
    client_loglevel    => $mng_agent::mco_client_loglevel,
  }

  package { $mng_agent::params::package_name: }
  package { $mng_agent::params::plugins_package_name: }

  # This should be a dependency, but installing here until we do better package
  # roles definition.
  package { 'ntteam-wmi': }

  Anchor['mcollective::end'] -> Class['mng_agent::config']
}
