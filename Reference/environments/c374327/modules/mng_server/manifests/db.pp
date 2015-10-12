# == Class: mng_server::db
#
class mng_server::db (
  $backend = 'postgresql',
  $django_address = '127.0.0.1/32',
  $django_database = 'management',
  $django_password = 'management',  # dev password, to be changed for production
  $django_user = 'management',
  $graphite_address = '127.0.0.1/32',
  $graphite_database = 'graphite',
  $graphite_password = 'graphite',
  $graphite_user = 'graphite',
  $listen_addresses = undef,  # default is localhost, '*' for all
  $manage_firewall = true,
  $manage_django_db = true,
  $manage_django_test_db = false,
  $manage_graphite_db = true,
  $server_password = 'changeme',
){
  if $django_password == 'management' {
    warning 'You are using default Django password!'
  }

  if $graphite_password == 'graphite' {
    warning 'You are using default Graphite password!'
  }

  if $server_password == 'changeme' {
    warning 'You are using default PostgreSQL server password!'
  }

  include "mng_server::db::${backend}"
}
