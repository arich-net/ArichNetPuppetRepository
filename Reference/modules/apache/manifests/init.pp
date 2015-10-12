# Class: apache
#
# This class installs Apache
#
# Operating systems:
#	:Working
#		Ubuntu 10.04
#		RHEL5
# 	:Testing
#
# Parameters:
#
# Actions:
#   - Install Apache
#   - Manage Apache service
#
# Requires:
#
# Sample Usage:
#	include apache
#
class apache {
  include apache::params

  package { 'httpd': 
    name   => $apache::params::apache_name,
    ensure => present,
  }

  service { 'httpd':
    name      => $apache::params::apache_name,
    ensure    => running,
    enable    => true,
    subscribe => Package['httpd'],
  }
 
  #
  # May want to purge all none realize modules using the resources resource type.
  #
  A2mod { require => Package['httpd'], notify => Service['httpd']}
  # Define some generic mods to enable, we might need to disable some and move them to 
  # more appropriate modules to enable per class etc.
  @a2mod {
   'rewrite' : ensure => present;
   'headers' : ensure => present;
   'expires' : ensure => present;
   'proxy'   : ensure => present;
  }
  A2mod <|  |>
    
  file { $apache::params::vdir:
    ensure => directory,
    recurse => true,
    purge => true,
    notify => Service['httpd'],
  }
   
}
