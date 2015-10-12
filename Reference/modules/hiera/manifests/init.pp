# Class: hiera
#
# Since puppet 3.x puppet_hiera is included and therefore we will mainly use this module to
# deploy custom backends.
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
#	include hiera
#
class hiera() {
	include hiera::params

	file {"${hiera::params::backend_dir}":
		ensure => directory,
		source => ["puppet:///files-environment/$::environment/files/hiera/backend",
		           "puppet:///hiera/backend"],
    recurse => true,		           
		owner => root,
		group => root,
	}
	 
}