# Class: djbdns::dnscache::rootserver
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
define djbdns::dnscache::rootserver($rootserver = []) {
	include djbdns::params
	# $name is the filename (10.10.10.in-addr.arpa)
	# $rootserver is the array of ip's used in the file ('2.2.2.2','4.4.4.4')
	file { "${djbdns::params::dnscache_basedir}/root/servers/${name}":
		ensure 	=> present,
		owner   => root,
		group   => root,
		mode    => 0644,
		content => template("djbdns/dnscache_rootserver.erb"),
	}
}