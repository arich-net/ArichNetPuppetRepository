# Class: nagios::server
#

class nagios::server ( $nagios_config_file_path = $::nagios::params::config_file_path,
                     ) inherits nagios {

  include nagios::params

  file { "$nagios::params::config_file_path":
      owner                 => "root",
      group                 => "root",
      require               => Package["$nagios::params::package_name"],
      ensure                => present,
      mode                  => 0644,
  }

}
