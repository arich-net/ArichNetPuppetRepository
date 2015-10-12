node 'evl2400261.parsfr02.infra.ntt.eu' {
	 
	# 
	#IP Settings
	#
	networking::interfaces::managed_interface{ "eth0":
		ensure   => "present",
		device  => "eth0",
		ipaddr  => "83.231.220.68",
		netmask => "255.255.255.192",
		up  => true,
	}
	networking::interfaces::managed_interface{ "eth1":
		ensure   => "present",
		device  => "eth1",
		ipaddr  => "192.168.220.68",
		netmask => "255.255.255.192",
		up  => true,
	}
    
	#	
	# Users : Local : as per nexus
	#
	class { 'c336792::users::root': 
		pass => '$6$GZeeNBNT$YkQwiNOVtGhb0iNz9lAvXSfFIUD53crsgrFld2RnZnqMcudSsOm1KKvUxH7CsPym8htLpaVtQIk9crwZL5wKd/',
	}
	class { 'c336792::users::nttuser': 
		pass => '$6$eLwdi0p4$.KEP8aFL.Np6VWhe.egV9vo9iLdsuE5Yk8ndhX8vjQcvj0cZ8uetyHqIZA4jEzVw2D/Q6Lh/WYKPf3sftf63a1',
	}
	class { 'c336792::users::custuser': 
		pass => '$6$WM8f0nlg$La7K2H6pf5CR.R.wW1b1OWKcZ2eq49/zh9/NA1A/x6eA5EFlAZwJnqWWtko7t18IOUG8DEx7UzXVSxC6iq.oH.',
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
		puppet_certname => 'puppetmaster.parsfr02.infra.ntt.eu',
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
	class { 'snmp': snmpro => "qAsJS7NL",}
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
    indexer => 'evl3300245.oob.eu.verio.net', 
  }
  # Splunk monitors
  class { 'c336792::splunkmonitors::global': }
  	
	# ActiveMQ - This is the stomphost and client for mcollective
	class { 'activemq':
		ldap => true,
		ldap_cert => 'nttengca.pem'
	}
	
	# Mcollective
	class { 'mcollective::server': identity => 'puppetmaster.parsfr02.infra.ntt.eu' }
	
	#
	# Classes (environment-modules)
	#
	

}

