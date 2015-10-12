node 'evl3300245.eu.verio.net' {
	
	# Node Variables
	$my_hostname = "evl3300245"
	$my_location = "londen01"
	$my_domain = "eu.verio.net"
	$my_snmpro = "PcCq2ADn"
	$my_snmprw = "PcCq2ADnPcCq2ADn"
 
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
	include hosts
	include core::hosts::backupservers
	include motd
	include ntp
	include sudo
	class { 'snmp': snmpro => "$my_snmpro",}
	class { 'ssh::server': ssh_usepam => 'yes', }
	resolver::resolv_conf { 'ntte_resolv':
		domainname  => "londen01.infra.ntt.eu",
		searchpath  => ['ntteng.ntt.eu', 'eu.verio.net'],
		nameservers => ['192.168.231.26', '192.168.231.8', '192.168.77.46'],
	}
	
	#
	# Ldap client
	# 
	include c336792::ldapclient
	
	#
	# Puppet
	#
	
	# Splunk
	class { 'splunk::forwarder':
	    indexer => 'evl3300244.eu.verio.net',
	    ssl => true,
		sslrootca => "cacert.pem",
		sslservercert => "evl3300245Cert.pem",
		sslpassphrase => '$1$ogkzUPniI9fN'
	}
	
	# Splunk monitors
	
	
	
	#
	# Classes (environment-modules)
	#
	

}

