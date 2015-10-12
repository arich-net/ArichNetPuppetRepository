# Class: apache::ssl
#
# This class installs Apache SSL capabilities
#
# Operating systems:
#	:Working
#		Ubuntu 10.04
#		RHEL5
# 	:Testing
#
# Parameters:
# - The $ssl_package name from the apache::params class
#
# Actions:
#   - Install Apache SSL capabilities
#
# Requires:
#
# Sample Usage:
#	class { 'apache::ssl':
#		ensure => 'present',
#	} 
#
class apache::ssl( $ensure = 'present' ) {

  include apache
  
  case $operatingsystem {
     'centos', 'fedora', 'redhat': {
        package { $apache::params::ssl_package:
        	ensure => $ensure,
			require => Package['httpd'],
        }
     }
     'ubuntu', 'debian': {
        a2mod { "ssl": ensure => $ensure, }
     }
  }
  
}