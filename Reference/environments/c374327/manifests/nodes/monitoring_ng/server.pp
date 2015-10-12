node server {
  $role = 'server'

  include 'apache'
  include 'mng_server::params'
  include 'mng_server'
  include 'mng_server::workers'
  include 'na_mcollective::puppetlabs'
}

node /services/ {
  $role = 'services'

  include 'grafana'
  include 'grafana::graphite::apache'
  include 'mng_server::activemq'
  include 'mng_server::broker'
  include 'mng_server::graphite' # must be before db
  include 'mng_server::db'
  include 'mng_server::riemann'
  include 'na_mcollective::puppetlabs'
}
