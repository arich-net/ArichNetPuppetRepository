# Class: yum
#
# This module manages yum for Redhat we can expand to Centos if required.
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
class yum {

    require yum::params

	case $::operatingsystem {
		/(?i)(redhat|centos)/: {
    
    	}
		default: { fail("no managed repo yet for this distro") }
  	}

	exec { "yum_update":
		command => "yum check-update",
		refreshonly => true,
	}

}