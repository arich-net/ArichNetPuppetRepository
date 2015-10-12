# == Class: graphite::web::config
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
class graphite::web::config {

  #### Configuration

  file { '/etc/graphite':
    ensure => directory,
    owner  => 'root',
    group  => 'root',
    mode   => '0644'
  }

  file { '/etc/graphite/local_settings.py':
    ensure  => present,
    content => template($graphite::web::local_settings_file),
    owner   => 'root',
    group   => 'root',
    mode    => '0644',
    require => File['/etc/carbon']
  }
}
