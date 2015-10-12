# Class: networking
#
# This module manages networking
#
# Parameters:
#
# Actions:
#
# Requires:
#
# Sample  Usage:
#
# [Remember: No empty lines between comments and class definition]
class networking {

#	service { 'networking' :
#		ensure => running,
#	}

	exec { "restart-networking":
		command => $::operatingsystem ? {
			Ubuntu => "service networking restart",
			Debian => "/etc/init.d/networking restart",
			Redhat => "/etc/init.d/network restart",
			Solaris => "svcadm restart network/physical",
			default => "",
		},
		refreshonly => true
	}
	
	
}
