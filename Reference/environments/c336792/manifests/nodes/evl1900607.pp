node 'evl1900607.mdrdsp04.infra.ntt.eu' {
	 
	# 
	#IP Settings
	#
	networking::interfaces::managed_interface{ "eth0":
		ensure   => "present",
		device  => "eth0",
		ipaddr  => "213.130.57.12",
		netmask => "255.255.255.192",
		up  => true,
	}
	networking::interfaces::managed_interface{ "eth1":
		ensure   => "present",
		device  => "eth1",
		ipaddr  => "192.168.57.12",
		netmask => "255.255.255.192",
		up  => true,
	}
    
	#	
	# Users : Local : as per nexus
	#
	class { 'c336792::users::root': 
		pass => '$6$j34KEN3m$6HB4MyvKwNsJvQTEDaAVKj0hHzALWal9OoXRUvsTY1TElFrpSWdFE1i5OEbQzhKOq955yHbl2sl4Nx8lKWYZH0',
	}
	class { 'c336792::users::nttuser': 
		pass => '$6$jcIvZSVB$EJKfLoLXYkbj1umSCnCshAXocaSK0JXQgAyxQxZ0yGtZ/3vV/EEfhdCO0xvBaRclxGb/2e8WZuCuA6BMwBKXX1',
	}
	class { 'c336792::users::custuser': 
		pass => '$6$slac4gK0$aj5OgoOo6V9irc6uSjqQbAb4.kxTTw5X.84GvlGHzRuyeJIvc.N7.DND03S7Mz88jw.146kTlHhQpNSOkJylV1',
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
		puppet_certname => 'puppetmaster.mdrdsp04.infra.ntt.eu',
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
	class { 'snmp': snmpro => "D3mVWWum",}
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
	class { 'mcollective::server': identity => 'puppetmaster.mdrdsp04.infra.ntt.eu' }
	
	#
	# Classes (environment-modules)
	#
	

}

