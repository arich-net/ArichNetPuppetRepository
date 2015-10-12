# Class: djbdns::dnscache::ubuntu
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
class djbdns::dnscache::ubuntu() {
	
	# These should be installed as part of djbdns dependencies.
	#
	#package { 'dnscache-run':
    #	ensure => present,
    #	require => [Package['daemontools'], Package['daemontools-run']],
	#}
	
	#package { 'daemontools-run':
    #	ensure => present,
    #	require => Package['daemontools'],
	#}
	
}