node 'eul2500002.eu.verio.net' {
	
	# Node Variables

	# 
	#IP Settings
	#
    
	#	
	# Users : Local : as per nexus
	#
	
	# 
	# Classes (core-modules)
	#
	class { 'core::default':
		puppet_environment => 'c336792',
	}
	class { 'c336792::default': } 
	class { 'apt': include_backports => true}
	
	#
	# Ldap client
	# 
	
	#
	# Puppet
	#
	
	# Mcollective
	class { 'mcollective::server': }
	
	#
	# Classes (environment-modules)
	#

	# CR-032454 (MinU)
	include djbdns::dnscache
	include c336792::dnscache	

}

