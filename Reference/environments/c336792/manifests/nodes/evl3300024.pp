node 'evl3300024.eu.verio.net' {
	
	# Node Variables
	$my_hostname = "evl3300024"
	$my_location = "londen01"
	$my_domain = "eu.verio.net"
	$my_snmpro = "QHYmJ7c2"
	$my_snmprw = "QHYmJ7c2QHYmJ7c2"
 
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
	include sudo	
	
	#
	# Include NTTE Scripts
	#
	include c336792::nttescripts
	
}

