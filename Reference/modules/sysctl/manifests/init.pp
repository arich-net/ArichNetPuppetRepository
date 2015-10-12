# Class: sysctl
#
# Maintains values in sysctl, currently using augeas.
#
# Operating systems:
#	:Working
#
# 	:Testing
#
# Parameters:
#
# Actions:
#
# Requires:
#
# Sample Usage:
#	include sysctl
#
class sysctl() {
	
	file { "sysctl_conf":
		path => $::operatingsystem ? {
			default => "/etc/sysctl.conf",
		},
	}

	exec { "sysctl_update":
		command => "sysctl -p",
		refreshonly => true,
		subscribe => File["sysctl_conf"],
	}

}