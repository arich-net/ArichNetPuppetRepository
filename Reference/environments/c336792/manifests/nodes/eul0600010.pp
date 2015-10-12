node 'eul0600010.eu.verio.net' {
	
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
	
	#
	# Splunk
	class { 'splunk::client':
		indexer => "evl3300245.eu.verio.net",
	}
	
	# Mcollective
	class { 'mcollective::server': }
	
	#
	# Classes (environment-modules)
	#

	# CR-032544 (Maj)
	include djbdns::dnscache
	include c336792::dnscache	

}

