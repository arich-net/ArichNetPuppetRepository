# Class: djbdns::dnscache
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
class djbdns::dnscache() {
	include djbdns
	
    case $::operatingsystem {
        debian: { include djbdns::dnscache::debian }
        ubuntu: { include djbdns::dnscache::debian }
        default: { include djbdns::dnscache::debian }
    }
    
	exec { 'dnscache_setup':
		command => "/usr/bin/dnscache-conf dnscache dnslog ${djbdns::params::dnscache_basedir}",
		creates => "${djbdns::params::dnscache_basedir}/run",
		require => Package['djbdns'],
	}
	
	service { "dnscache":
    	provider => "daemontools",
    	ensure => "running",
    	require => [ Package['djbdns'], Exec['dnscache_setup'] ],
	}
  
	file { "${djbdns::params::dnscache_basedir}/root/ip/":
		ensure => directory,
		purge => true, 
		recurse => true,
		force => true,
		require => Exec['dnscache_setup'],
	}
	
	
	


}