# Class: ruby
#
# This module manages ruby
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
class ruby() {
  include ruby::params

	case $::operatingsystem {
    	/RedHat|CentOS|Fedora/: { include base }
    	/Debian|Ubuntu/: { include base }
    	windows: { include windows}
    	default: { notify{"Module $module_name is not supported on os: $::operatingsystem, arch: $::architecture": } }
  	}
  	
  	class base() {
		package{'ruby': 
			ensure => installed,
			require => $::operatingsystem ? {
					ubuntu => [Class["apt"], Exec['apt-get_update']],
					debian => [Class["apt"], Exec['apt-get_update']],
					redhat => [Class["yum"], Exec['yum_update']],
					windows => undef,
					default => undef,
			}
		}
		package{'rubygems': 
			ensure => installed,
			require => $::operatingsystem ? {
					ubuntu => [Package['ruby'], Class["apt"], Exec['apt-get_update']],
					debian => [Package['ruby'], Class["apt"], Exec['apt-get_update']],
					redhat => [Package['ruby'], Class["yum"], Exec['yum_update']],
					windows => undef,
					default => undef,
			} 
		}
	}
	
	class windows() {
		# Just in case we need to manage ruby, at the moment it is packaged as part of puppet msi.
	}

}
