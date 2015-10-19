# Class: ssh::client
#
# This module installs and manages the openssh-client
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
class ssh::client inherits ssh::params {
	
	include ssh::config::firewall::client
	
	package { ssh:
		name => $::operatingsystem ? {
			"ubuntu" => "openssh-client",
			"debian" => "openssh-client",
			"redhat" => "openssh-clients",
			"centos" => "openssh-clients",
			default => "openssh-client",
		},
		ensure => present,
	}
	
}