# == Class: mng_server::db::postgresql::django
#
class mng_server::db::postgresql::django {
  $address = $mng_server::db::django_address
  $database = $mng_server::db::django_database
  $password = $mng_server::db::django_password
  $user = $mng_server::db::django_user

  postgresql::server::pg_hba_rule { 'allow monitoring-ng django db access':
    type        => 'host',
    database    => $database,
    user        => $user,
    address     => $address,
    auth_method => 'md5',
  }

  postgresql::server::role { $user:
    password_hash => postgresql_password($user, $password),
    login         => true,
  }

  postgresql::server::database { $database:
    owner   => $user,
    require => Postgresql::Server::Role[$user],
  }

  if defined(Exec['monitoring-ng syncdb']) {
    Postgresql::Server::Database[$database] ~> Exec['monitoring-ng syncdb']
  }

  if $mng_server::db::manage_django_test_db {
    # Here settings are hardcoded because test settings are
    Postgresql::Server::Role['management'] {
      superuser => true,
    }

    postgresql::server::database { 'test_management':
      owner   => 'management',
      require => Postgresql::Server::Role['management'],
    }

    postgresql::server::pg_hba_rule { 'allow monitoring-ng django testing':
      type        => 'host',
      database    => 'test_management',
      user        => 'management',
      address     => '0.0.0.0/0',
      auth_method => 'md5',
    }
  }
}
