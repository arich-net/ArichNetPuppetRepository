# == Class: mng_server::settings
#
class mng_server::settings {
  include 'mng_server::params'

  mng_server::setting { 'DATABASE_URL':
    value => $mng_server::params::database_url,
  }

  mng_server::setting { 'BROKER_URL':
    value => $mng_server::params::broker_url,
  }

  mng_server::setting { 'NEXUS_SAB_PASSWORD':
    value => $mng_server::params::nexus_sab_password,
  }

  mng_server::setting { 'DEBUG':
    value => $mng_server::params::debug,
  }

  mng_server::setting { 'SECRET_KEY':
    value => $mng_server::params::secret_key,
  }

  mng_server::setting { 'ACTIVEMQ_HOST':
    value => $mng_server::params::activemq_host,
  }

  mng_server::setting { 'ACTIVEMQ_PORT':
    value => $mng_server::params::activemq_port,
  }

  mng_server::setting { 'ACTIVEMQ_USER':
    value => $mng_server::params::activemq_user,
  }

  mng_server::setting { 'ACTIVEMQ_PASSWORD':
    value => $mng_server::params::activemq_password,
  }

  mng_server::setting { 'GRAPHITE_URL':
    value => $mng_server::params::graphite_url,
  }

  mng_server::setting { 'RIEMANN_HOST':
    value => $mng_server::params::riemann_host,
  }

  mng_server::setting { 'DJANGO_SETTINGS_MODULE':
    value => $mng_server::params::settings,
  }
}
