# == Class: mng_server::db::postgresql::graphite
#
class mng_server::db::postgresql::graphite {
  $address = $mng_server::db::graphite_address
  $database = $mng_server::db::graphite_database
  $user = $mng_server::db::graphite_user
  $password = $mng_server::db::graphite_password

  postgresql::server::pg_hba_rule { 'allow monitoring-ng graphite db access':
    type        => 'host',
    database    => $database,
    user        => $user,
    address     => $address,
    auth_method => 'md5',
  }

  postgresql::server::db { $database:
    password => $password,
    user     => $user,
  }

  if defined(Exec['Graphite syncdb']) {
    Postgresql::Server::Db[$database] ~> Exec['Graphite syncdb']
  }
}
