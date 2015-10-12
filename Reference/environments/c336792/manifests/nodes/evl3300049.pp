node 'evl3300049.eu.verio.net' {
	
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
	include yum
	#
	# Ldap client
	# 
	
	#
	# VMware tools
	#
	include vmwaretools
	
	#
	# Puppet
	#
	
	# Mcollective
	class { 'mcollective::server': }
	
	
	#
	# Classes (environment-modules)
	#

	
}

