node 'evl3300054.ntteng.ntt.eu' {
	
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
	class { 'c336792::default':} 
	include apt
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

	
}

