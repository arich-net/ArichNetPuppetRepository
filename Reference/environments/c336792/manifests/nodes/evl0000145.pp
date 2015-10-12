node 'evl0000145.londen02.infra.ntt.eu' {
	
	# Node Variables
	$my_hostname = "evl0000145"
	$my_location = "londen02"
	$my_domain = "londen02.infra.ntt.eu"
	$my_snmpro = "fqBYPKa8"
	$my_snmprw = "fqBYPKa8fqBYPKa8"
 
	# 
	#IP Settings
	#
	networking::interfaces::managed_interface{ "eth0":
		ensure   => "present",
		device  => "eth0",
		ipaddr  => "213.130.39.33",
		netmask => "255.255.255.224",
		up  => true,
	}
	networking::interfaces::managed_interface{ "eth1":
		ensure   => "present",
		device  => "eth1",
		ipaddr  => "192.168.56.33",
		netmask => "255.255.255.224",
		up  => true,
	}
	
	networking::routes::managed_route{ "192.168.0.0/16":
		ensure   => "present",
		network => "192.168.0.0",
		subnet => "255.255.0.0",
		gateway => "192.168.56.62",
		interface => "eth1",
	}
	
	networking::routes::managed_route{ "10.0.0.0/8":
		ensure   => "present",
		network => "10.0.0.0",
		subnet => "255.0.0.0",
		gateway => "192.168.56.62",
		interface => "eth1",
	}
    
	#	
	# Users : Local : as per nexus
	#
	class { 'c336792::users::root': 
		pass => '$6$XrCfWe3m$HElpK90p69r10AmSl1.p5VKPWNby4nnMm6fSU1JiBp3053gzv0mF6gw8pmS9f.AKtfhnS1WCmC7tjQaksRlyH0',
	}
	class { 'c336792::users::nttuser': 
		pass => '$6$DNes0spB$Zj9uZqmxBtaqSW2iVUUgMnmzYp7du0Vc.1IP2neuwsrXbYBmlFg3AqeOkguh30PiMrD6tNP0LkhqC8r.pJBSm1',
	}
	class { 'c336792::users::custuser': 
		pass => '$6$Og2nE7HK$9H7gghY8FvE1tM9VQAF.QU.NpkoHasEGNeJ1XTc6JYRggqWduz.ZZF/XsHHJUbQCCSbfNB2Kr9pHYiAshX8Mj/',
	} 
	
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
		puppet_certname => 'puppetmaster.londen02.infra.ntt.eu',
		puppet_role => 'master'
	}
	class { 'c336792::default': }
	include hosts
	include motd
	include ntp
	include sudo
	include subversion
	class { 'apt': }
	class { 'snmp': snmpro => "$my_snmpro",}
	class { 'ssh::server': ssh_usepam => 'yes', }
	resolver::resolv_conf { 'ntte_resolv':
		domainname  => "londen02.infra.ntt.eu",
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

  # Splunk
  class { 'splunk::client':
    indexer => 'evl3300245.oob.eu.verio.net', 
  }
  # Splunk monitors
  class { 'c336792::splunkmonitors::global': }

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
	class { 'mcollective::server': identity => 'puppetmaster.londen02.infra.ntt.eu'}
	
	#
	# Classes (environment-modules)
	#
	

}

