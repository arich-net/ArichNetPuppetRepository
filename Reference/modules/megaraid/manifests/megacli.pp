# Class: megaraid::megacli
#
# Installs MegaCLI for management of Megaraid SAS Cards
#
# Operating systems:
# :Working
#
#   :Testing
#
# Parameters:
# List of all parameters used in this class
#
# Actions:
# List of any outstanding actions or notes for changes to be made.
#
# Requires:
# Class requirements
#
# Sample Usage:
# include megaraid
#
class megaraid::megacli() {
  include megaraid
  
  file { "$megaraid::params::file_path_local$megaraid::params::megacli_pkg":
    owner   => root,
    group   => root,
    mode    => 644,
    ensure  => present,
    source  => "${megaraid::params::file_path_remote}${megaraid::params::megacli_pkg}",
  }

  package { $megaraid::params::megacli_pkg:
    name => $megaraid::params::megacli_pkg_name,
    ensure => latest,
    provider => $megaraid::params::megacli_pkg_provider,
    source => "$megaraid::params::file_path_local$megaraid::params::megacli_pkg",
    require => File["$megaraid::params::file_path_local$megaraid::params::megacli_pkg"]
  }
  
  exec { "update-alternatives --install /usr/bin/MegaCli MegaCli ${megaraid::params::megacli_path} 1":
    path => '/bin:/sbin:/usr/bin:/usr/sbin',
    unless => "test /etc/alternatives/MegaCli -ef ${megaraid::params::megacli_path}",
    require => Package[$megaraid::params::megacli_pkg]
  }
    
}