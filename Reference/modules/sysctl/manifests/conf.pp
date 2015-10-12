# Define: sysctl::conf
#
# Adds/Updates the entries in sysctl.conf
#
# Operating systems:
#	:Working
#
# 	:Testing
#
# Parameters:
#	$name = the name of the parameter you are changing, passed to the define as the 'title'
#	$value = value given for parameter.
#
# Actions:
#
# Requires:
#
# Sample Usage:
#	sysctl::conf { 
#		"net.ipv4.ip_forward": value =>  1;
#		"net.ipv4.conf.all.accept_redirects": value =>  0;
#	}
#
define sysctl::conf($value) {
	
	include sysctl

	augeas { "sysctl_conf/$name":
		context => "/files/etc/sysctl.conf",
		onlyif  => "get $name != '$value'",
 		changes => "set $name '$value'",
		notify  => Exec["sysctl_update"],
	}

}