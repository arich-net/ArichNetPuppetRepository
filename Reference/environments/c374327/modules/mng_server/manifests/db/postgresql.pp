# == Class: mng_server::db::postgresql
#
class mng_server::db::postgresql {
  # TODO (rafaduran): setting up SSL connections
  class { 'postgresql::server':
    listen_addresses  => $mng_server::db::listen_addresses,
    manage_firewall   => $mng_server::db::manage_firewall,
    postgres_password => $mng_server::db::server_password,
  }

  if $mng_server::db::manage_django_db {
    include 'mng_server::db::postgresql::django'
  }

  if $mng_server::db::manage_graphite_db {
    include 'mng_server::db::postgresql::graphite'
  }
}
