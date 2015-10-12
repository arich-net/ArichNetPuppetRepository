# Class: daemontools::base
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
class daemontools::base() {
	package{'daemontools':
		ensure => installed,
	}
	
	file { "/etc/service":
		ensure => directory,
		require => Package['daemontools'],
	}
	
	# This is added to init /etc/init/svscan.conf by .deb but never started.
	# Start manually unless already running.
	exec{'svscanboot &':
		unless => 'ps ax | grep -v grep | grep -q svscan',
		require => File['/etc/service'],
	}

}