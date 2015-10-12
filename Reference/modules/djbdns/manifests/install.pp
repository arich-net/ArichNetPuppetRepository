# Class: djbdns::install
#
# This module manages djbdns
#
# Parameters:
#
# Actions:
#
# Requires:
#
# Sample Usage:
#
# [Remember: No empty lines between comments and class definition]
class djbdns::install() {
	include daemontools
	
	package { 'djbdns':
    	ensure => present,
    	require => Package['daemontools'],
	}
  	
}