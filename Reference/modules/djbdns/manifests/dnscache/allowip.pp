# Class: djbdns::dnscache::allowip
#
# Specifics for dnscache on ubuntu
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
define djbdns::dnscache::allowip() {
	include djbdns::params
	file { "${djbdns::params::dnscache_basedir}/root/ip/${name}":
		ensure 	=> present,
		owner   => root,
		group   => root,
		mode    => 0644,
	}
}