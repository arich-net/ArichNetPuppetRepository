node 'evl3301398.londen01.infra.ntt.eu' {
	
	#	
	# Users : Local : as per nexus
	#

	#
	# Users : In global environment (environment/manifests/baselines/users.pp)
	#
	realize (Users::Local::Localuser["puppetadmin"])

	# 
	# Classes (core-modules)
	#
	class { 'core::default':
		puppet_environment => 'c336792',
		puppet_master => 'puppeteer.londen01.infra.ntt.eu',
		puppet_certname => 'puppetmaster-dev.londen01.infra.ntt.eu',
		puppet_role => 'master'
	}
	class { 'c336792::default': }
	include hosts
	include motd
	include ntp
	include sudo
	include subversion
	class { 'apt': }
	class { 'snmp': snmpro => "M9dhUAv9",}
	class { 'ssh::server': ssh_usepam => 'yes', }
	resolver::resolv_conf { 'ntte_resolv':
		domainname  => "londen01.infra.ntt.eu",
		searchpath  => ['ntteng.ntt.eu', 'eu.verio.net'],
		nameservers => ['192.168.46.251', '192.168.231.26', '192.168.77.46'],
	}
	
	# Apache
	include apache
	include apache::passenger
	  
	#
	# Ldap client
	#
	include c336792::ldapclient
	
	#
	# Puppet
	#
	class { 'puppet::master':
		puppet_passenger => true
	}

  class { 'c336792_sysapi': }
  
  # 
  # VMWARE Tools
  #
  include vmwaretools
  
	# ActiveMQ - This is the stomphost and client for mcollective
	class { 'activemq':
		ldap => true,
		ldap_cert => 'nttengca.pem'
	}
	
	# Mcollective
	class { 'mcollective::client': }
	class { 'mcollective::server': identity => 'puppetmaster-dev.londen01.infra.ntt.eu'}
	
	#
	# Classes (environment-modules)
	#
	

}

