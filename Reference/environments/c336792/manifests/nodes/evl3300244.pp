node 'evl3300244.eu.verio.net' {
	
	# Node Variables
	$my_hostname = "evl3300244"
	$my_location = "londen01"
	$my_domain = "eu.verio.net"
	$my_snmpro = "LaJQrr6M"
	$my_snmprw = "LaJQrr6MLaJQrr6M"
 
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

  #
  # Splunk and SysAPI Integration
  #
  class { 'c336792_sysapiclient': }
	
	# Splunk
	class { 'splunk::indexer':
	    	ssl => true,
			sslrootca => "cacert.pem",
			sslservercert => "evl3300244Cert.pem",
			sslpassphrase => '$1$wZ0GZXt9PC2F'
	    }
	    
	splunk::authldap { 'ntteng':
		host => 'evw3300026.ntteng.ntt.eu',
		port => '636',
		search_base => 'ou=NTT EO,dc=ntteng,dc=ntt,dc=eu', 
		bind_dn => 'cn=NTTEO LDAP Service,cn=Users,dc=ntteng,dc=ntt,dc=eu', 
		bind_passwd => '$1$9ZokQD9oWx2v5wY=',
	}
	
	
	#
	# Classes (environment-modules)
	#
	

}

