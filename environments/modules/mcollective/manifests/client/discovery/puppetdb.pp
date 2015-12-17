class mcollective::client::discovery::puppetdb (
  $puppetdb = 'localhost',
  $use_ssl  = true,
  $ssl_key  = $mcollective::client::broker_ssl_key,
  $ssl_cert = $mcollective::client::broker_ssl_cert,
  $ssl_ca   = $mcollective::client::broker_ssl_ca,
) {
  $cfgdir = $mcollective::params::cfgdir
  validate_absolute_path($cfgdir)

  if $use_ssl {
    $content = "
plugin.discovery.puppetdb.use_ssl = y
plugin.discovery.puppetdb.host = ${puppetdb}
plugin.discovery.puppetdb.port = 8081
plugin.discovery.puppetdb.ssl_ca = ${ssl_ca}
plugin.discovery.puppetdb.ssl_cert = ${ssl_cert}
plugin.discovery.puppetdb.ssl_private_key = ${ssl_key}
"
  } else {
    $content = "
plugin.discovery.puppetdb.use_ssl = n
plugin.discovery.puppetdb.host = ${puppetdb}
plugin.discovery.puppetdb.port = 8080
"
  }

  concat::fragment { 'mcollective client.cfg puppetdb discovery':
    ensure  => 'present',
    order   => '99',
    target  => "${cfgdir}/client.cfg",
    content => $content,
  }

  package { 'mcollective-puppetdb-discovery-discovery':
    ensure => present,
  }
}
