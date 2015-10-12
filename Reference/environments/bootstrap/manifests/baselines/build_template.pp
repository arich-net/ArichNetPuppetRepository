# Class: bootstrap::build_template
#
# Used to configure the standard build template image i.e 'Ubuntu 12.04 x64 default template'
#
#	1) Does not run full bootstrap, only what we need to do before we clone to template.
#
# Parameters:
#
# Actions:
#
# Requires:
#
# Sample Usage:
#
#	include bootstrap::build_template
#	class { 'bootstrap::build_template': }
#
# [Remember: No empty lines between comments and class definition]
class bootstrap::build_template() {
		
	# Prep system to be cloned to template.		
	#

	# This makes sure that when the system is cloned and mcollective starts it
	# will enable the bootstrap agent.
	file { "/etc/mcollective/bootstrap.enable":
    	ensure => present,
    	require => Package["mcollective"],
	}
	
	class {'vmwaretools': }
	
	# Prevents system from hanging on boot if grub detects a failure
	# after a template has been deployed.
	# MOVE THIS INTO A CORE MODULE 
	augeas { 'grub_config_timeout':
		context => '/files/etc/default/grub',
		changes => [ 'set GRUB_RECORDFAIL_TIMEOUT "5"' ],
		notify => Exec["update-grub"],
	}
	exec { "update-grub":
		command => "update-grub",
		refreshonly => true,
	}
	
	## Dirty hack
	# ensure mcollective scope facts do NOT exist as these will screw up the facter facts when we
	# go to deploy a vm from the template.
	# We can remove this by fixing mcollective to only create this file if we are not building a template
	# or possibly something in the bootstrap agent.
	exec { "remove_mc_scope_facts":
		command => "rm /etc/mcollective/scope_facts.yaml",
		require => File["/etc/mcollective/scope_facts.yaml"],
	}

	## Create a symlink to dhcp3 because some VMware Guest Customization Issues
	case $::lsbdistcodename {
		/(?i)(trusty)/ : {
			file { '/etc/dhcp3'
				ensure => 'link',
				target => '/etc/dhcp',
			}
		}
	}
} 
