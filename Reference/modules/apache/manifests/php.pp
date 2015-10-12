# Class: apache::php
#
# This class installs PHP for Apache
#
# Operating systems:
#	:Working
#		Ubuntu 10.04
#		RHEL5
# 	:Testing
#
# Parameters:
# - $ensure = present/absent
#
# Actions:
#   - Install Apache PHP package
#
# Requires:
#
# Sample Usage:
#	class { 'apache::php':
#		ensure => 'present',
#	} 
#
class apache::php( $ensure ) {

  include apache::params

  package { $apache::params::php_package:
    ensure => $ensure,
    require => Package['httpd'],
  }
  
}