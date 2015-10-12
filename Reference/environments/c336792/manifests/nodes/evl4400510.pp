node 'evl4400510.londen08.infra.ntt.eu' {
	
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
		puppet_certname => 'puppetmaster.londen08.infra.ntt.eu',
		puppet_role => 'master'
	}
	class { 'c336792::default': }
	include hosts
	include motd
	include ntp
	class { 'sudo': sudoers => "puppetmasters_sudoers.erb"}
	include subversion
	class { 'apt': }
	class { 'snmp': snmpro => "MRhB5KbZ",}
	class { 'ssh::server': ssh_usepam => 'yes', }
	resolver::resolv_conf { 'ntte_resolv':
		domainname  => "londen08.infra.ntt.eu",
		searchpath  => ['ntteng.ntt.eu', 'eu.verio.net'],
		nameservers => ['192.168.231.26', '192.168.231.8', '192.168.77.46'],
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

  # Splunk
  class { 'splunk::client':
    indexer => 'evl3300245.eu.verio.net', 
  }
  # Splunk monitors
  class { 'c336792::splunkmonitors::global': }
  	
	# ActiveMQ - This is the stomphost and client for mcollective
	class { 'activemq':
		ldap => true,
		ldap_cert => 'nttengca.pem'
	}
	
	# Mcollective
	class { 'mcollective::server': identity => 'puppetmaster.londen08.infra.ntt.eu' }
	
	#
	# Classes (environment-modules)
	#
	

}

