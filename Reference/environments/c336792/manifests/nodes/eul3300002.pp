node 'eul3300002.eu.verio.net' {
	
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
	# Disabled temporarilly as it generates too much data in Splunk
	#splunk::config::client::monitor { "/service/dnscache/log/main/*": type => 'log', index => 'dns' }
	
	
	# Mcollective
	class { 'mcollective::server': }
	
	#
	# Classes (environment-modules)
	#

	# CR-032544 (Maj)
	include djbdns::dnscache
	include c336792::dnscache

}
