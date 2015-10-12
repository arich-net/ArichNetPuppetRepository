#Class: clamav::params
#
# Inherited parameters for class: clamav
#
# Operating systems:
#
# Parameters:
#	$runasdaemon = true/false : boolean
#	$cron_command = command to run when $runasdaemon is set to false
#	$cron_hour = hour to run command
#	$cron_minute = minute to run command
#	$clamav_package = package name (os dependant)
#	$clamav_daemon_package = package name (os dependant)
#
# Actions:
#
# Requires:
#
# Sample Usage:
#	Not directly called
#
class clamav::params() {

	$runasdaemon = true
	
	# Cron varibales
	$cron_enable = false
	$cron_command = "clamscan -r / > /dev/null 2>&1"
	$cron_hour = "0"
 	$cron_minute = "0"
 	
	case $::operatingsystem {
    	'centos', 'redhat', 'fedora': {
      		$clamav_package = [ 'clamav' ]
    	}
    	'ubuntu', 'debian': {
    		$clamav_package = [ 'clamav', 'clamav-daemon' ]
    	}
 	}
 	
 	# Proxy settings
 	$proxy_server = undef
 	$proxy_port = undef
 	$proxy_username = undef
 	$proxy_password = undef
}