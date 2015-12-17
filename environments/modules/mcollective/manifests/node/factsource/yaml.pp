class mcollective::node::factsource::yaml {
  $excluded_facts      = []
  $yaml_fact_path_real = "${mcollective::params::cfgdir}/facts.yaml"

  # Template uses:
  #   - $yaml_fact_path_real
  file { "${mcollective::params::libdir}/refresh-mcollective-metadata":
    owner   => '0',
    group   => '0',
    mode    => '0755',
    content => template('mcollective/refresh-mcollective-metadata.erb'),
  } ->
  cron { 'refresh-mcollective-metadata':
    environment => 'PATH=/opt/puppetlabs/puppet/bin:/opt/puppet/bin:/usr/local/bin:/usr/local/sbin:/usr/bin:/usr/sbin:/bin:/sbin',
    command     => "${mcollective::params::libdir}/refresh-mcollective-metadata",
    user        => 'root',
    minute      => [ '0', '15', '30', '45' ],
  }

  exec { 'create-mcollective-metadata':
    path    => '/opt/puppetlabs/puppet/bin:/opt/puppet/bin:/usr/local/bin:/usr/local/sbin:/usr/bin:/usr/sbin:/bin:/sbin',
    command => "${mcollective::params::libdir}/refresh-mcollective-metadata",
    creates => $yaml_fact_path_real,
    require => File["${mcollective::params::libdir}/refresh-mcollective-metadata"],
  }
}
