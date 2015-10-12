# == Class: mng_agent
#
class mng_agent (
  # roles
  $poller = false,
  $mco_client = false,
  $mco_server = true,

  # core configuration
  $mco_main_collective = undef,
  $mco_collectives = undef,

  # networking
  $mco_middleware_admin_password = undef,
  $mco_middleware_admin_user = undef,
  $mco_middleware_hosts = undef,
  $mco_middleware_password = undef,
  $mco_middleware_port = undef,
  $mco_middleware_ssl = undef,
  $mco_middleware_ssl_port = undef,
  $mco_middleware_user = undef,

  # server-specific
  $mco_server_daemonize = undef,
  $mco_server_logfile = undef,
  $mco_server_loglevel = undef,
  $mco_securityprovider = undef,

  # client-specific
  $mco_client_logger_type = undef,
  $mco_client_loglevel = undef,

  # wmi specific
  $wmic = undef,
){
  include 'mng_agent::params'
  include 'cleng'

  Class['cleng'] ->
  class { 'mng_agent::install': } ->
  class { 'mng_agent::config': } ~>
  class { 'mng_agent::service': } ->
  Class['mng_agent']
}
