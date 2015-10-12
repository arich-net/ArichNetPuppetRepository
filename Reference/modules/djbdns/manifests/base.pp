# Class: djbdns::base
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
class djbdns::base() {

	include daemontools
	
	users::local::localuser { "tinydns":
	 		ensure => "present",
	 		uid => "201",
	 		gid => "201",
	 		managehome => false,
	 		comment => "TinyDNS Service",
	 		before => Package['djbdns']
		}
	users::local::localuser { "dnscache":
	 		ensure => "present",
	 		uid => "202",
	 		gid => "202",
	 		managehome => false,
	 		comment => "DNSCache Service",
	 		before => Package['djbdns']
		}
	users::local::localuser { "dnslog":
	 		ensure => "present",
	 		uid => "203",
	 		gid => "203",
	 		managehome => false,
	 		comment => "DNSlog Service",
	 		before => Package['djbdns']
		}
	users::local::localuser { "axfrdns":
	 		ensure => "present",
	 		uid => "204",
	 		gid => "204",
	 		managehome => false,
	 		comment => "axfrdns Service",
	 		before => Package['djbdns']
		}
		
}
