# Class: djbdns::tinydns
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
class djbdns::tinydns() {
	include djbdns
	
	service { "tinydns":
    	provider => "daemontools",
    	ensure => "running",
	}
	
	exec { 'tiny_dns_setup':
		command => "/usr/bin/tinydns-conf tinydns dnslog /etc/tinydns $::ipaddress",
		creates => "/etc/tinydns/env/IP",
		require => Package['djbdns'],
	}
	
	exec { 'axfr_dns_setup':
    	command => "/bin/axfrdns-conf axfrdns dnslog /etc/axfrdns /etc/tinydns $::ipaddress",
    	creates => "/etc/axfrdns/env/IP",
    	require => Package['djbdns'],
	}
	
	# tcp file, must be made afterwards
	file { "/etc/axfrdns/tcp":
    	source => [ "puppet:///files-environment/$::environment/files/djbdns/axfrdns_tcp",
    				"puppet:///modules/djbdns/axfrdns_tcp",	
    	],
    	require => Package['djbdns'],
    	owner => tinydns, group => 0, mode => 0644;
  	}
	exec { "/usr/bin/make -f /etc/axfrdns/Makefile -C /etc/axfrdns/":
    	subscribe => File["/etc/axfrdns/tcp"],
		require => Package['djbdns'],
    	refreshonly => true
	}

	# Used to generate data.cdb (zone entries) 
	# This isn't needed as nexus handles this.
	# But I used for testing and demostration purposes.
	#file{'djbdns_data_file':
	#	path => '/etc/tinydns/root/data',
	#	source => "puppet:///modules/djbdns/data",
    #	require => Package['djbdns'],
   	#	notify => Exec['generate_data_db'],
	#	owner => root, group => 0, mode => 0644;
	#}
	#exec{'generate_data_db':
    #	command => 'make -f /etc/tinydns/root/Makefile -C /etc/tinydns/root/',
    #	refreshonly => true,
  	#}
	
}