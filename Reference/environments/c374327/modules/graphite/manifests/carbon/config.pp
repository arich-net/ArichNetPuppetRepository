# == Class: graphite::carbon::config
#
# This class exists to coordinate all configuration related actions,
# functionality and logical units in a central place.
#
#
# === Parameters
#
# This class does not provide any parameters.
#
#
# === Examples
#
# This class may be imported by other classes to use its functionality:
#   class { 'graphite::carbon::config': }
#
# It is not intended to be used directly by external resources like node
# definitions or other modules.
#
#
# === Authors
#
# * Richard Pijnenburg <mailto:richard@ispavailability.com>
#
class graphite::carbon::config {

  #### Configuration

  file { '/etc/carbon':
    ensure => directory,
    owner  => 'root',
    group  => 'root',
    mode   => '0644'
  }

  file { '/etc/default/graphite-carbon':
    content => inline_template('# Puppet managed file, do not edit
CARBON_CACHE_ENABLED=true'),
    owner   => 'root',
    group   => 'root',
    mode    => '0644',
  }

  file_fragment { "header_${::fqdn}":
    tag     => "carbon_cache_storage_config_${::fqdn}",
    content => template("${module_name}/etc/carbon/storage-schemas-header.erb"),
    order   => 01
  }

  file_concat { '/etc/carbon/storage-schemas.conf':
    tag     => "carbon_cache_storage_config_${::fqdn}",
    owner   => 'root',
    group   => 'root',
    mode    => '0644',
    require => File['/etc/carbon']
  }

  file { '/etc/carbon/carbon.conf':
    ensure  => present,
    source  => $graphite::carbon::config_file,
    owner   => 'root',
    group   => 'root',
    mode    => '0644',
    require => File['/etc/carbon']
  }
}
