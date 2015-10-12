# == Class: pypiserver
#
class pypiserver (
  $docroot = '/var/www/pypi',
  $manage_host = false,
  $server_name = undef,
  $user_hash = {},
){
  include 'pypiserver::params'

  $server_name_real = pick($server_name, "pypi.${::domain}")

  class { 'pypiserver::install': } ->
  class { 'pypiserver::service': } ->
  Class['pypiserver']
}
