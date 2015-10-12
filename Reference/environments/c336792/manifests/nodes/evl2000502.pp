node 'evl2000502.parsfr03.infra.ntt.eu' {
	 
	# 
	#IP Settings
	#
	networking::interfaces::managed_interface{ "eth0":
		ensure   => "present",
		device  => "eth0",
		ipaddr  => "83.217.251.100",
		netmask => "255.255.255.224",
		up  => true,
	}
	networking::interfaces::managed_interface{ "eth1":
		ensure   => "present",
		device  => "eth1",
		ipaddr  => "192.168.251.100",
		netmask => "255.255.255.224",
		up  => true,
	}
    
	#	
	# Users : Local : as per nexus
	#
	class { 'c336792::users::root': 
		pass => '$6$Ki.wvZzl$24YjKdhaeQ8f2TlzBZUNvPmX3Bbf/TJKCaSf5149yIyl6V3EB6ELTCxAjah0E/UasX8z02Xibnc/VVUZAfvkL1',
	}
	class { 'c336792::users::nttuser': 
		pass => '$6$qpclox2a$nBwGNERlQ9M1O8E5AEQrw93Z9WqB9Xymyi9wVRBdwlCGPI8bPJ5co85p7De5BQLU1TQgY7mGSMQxxxDueiArX1',
	}
	class { 'c336792::users::custuser': 
		pass => '$6$DVtLw1iJ$5wreM6vD.xWBSkXyXwr.gGMd2L7cku5xswiWF6ezze4PCbVqD7iar6QbowWZz8QfL.9rPujudx6/CfFETCDPo/',
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
		puppet_certname => 'puppetmaster.parsfr03.infra.ntt.eu',
		puppet_role => 'master'
	}
	class { 'c336792::default': }
	include hosts
	include core::hosts::backupservers
	include motd
	include ntp
	class { 'sudo': sudoers => "puppetmasters_sudoers.erb"}
	include subversion
	class { 'apt': }
	class { 'snmp': snmpro => "Yf8saJYp",}
	class { 'ssh::server': ssh_usepam => 'yes', }
	include c336792::resolv
	 
	# Apache
	include apache
	include apache::passenger
	 
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
	class { 'mcollective::server': identity => 'puppetmaster.parsfr03.infra.ntt.eu' }
	
	#
	# Classes (environment-modules)
	#
	

}

