node 'evl3300443.londen01.infra.ntt.eu' {
	
	# Node Variables
	$my_hostname = "evl3300443"
	$my_location = "londen01"
	$my_domain = "londen01.infra.ntt.eu"
	$my_snmpro = "GV5gSwys"
	$my_snmprw = "GV5gSwysGV5gSwys"
 
	# 
	#IP Settings
	#
	networking::interfaces::managed_interface{ "eth0":
		ensure   => "present",
		device  => "eth0",
		ipaddr  => "213.130.39.2",
		netmask => "255.255.255.224",
		up  => true,
	}
	networking::interfaces::managed_interface{ "eth1":
		ensure   => "present",
		device  => "eth1",
		ipaddr  => "192.168.231.102",
		netmask => "255.255.255.0",
		up  => true,
	}
    
	#	
	# Users : Local : as per nexus
	#
	class { 'c336792::users::root': 
		pass => '$6$g/VNtrwf$4yBM5Qy/SBjRd8cDySBPUkU7Jj7nksLyK9HcolqwEj7M54C1D1wIvpfKOTWwR8jIjka.wa4R0RrnFe6epH629.',
	}
	class { 'c336792::users::nttuser': 
		pass => '$6$ywTMbaZv$BNM9lvd7AsZL5JkH0wDn11aZlAzL9J22Zzgm6tyWlat8wuCEG9YoT5p/XVu6n7X/fvx0IWfB5gtemVzf1bYaV0',
	}
	class { 'c336792::users::custuser': 
		pass => '$6$LBdKToM2$c2gQ85lL6cc8mz9EuHxOl6CbsH2FzbUbyGbhnYGLlDVd2bNXirVgeFuTQCUdPEdw/NvWfqJeJ5HUHoXeVZSMV1',
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
		puppet_certname => 'puppetmaster.londen01.infra.ntt.eu',
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
	class { 'snmp': snmpro => "$my_snmpro",}
	class { 'ssh::server': ssh_usepam => 'yes', }
	include c336792::resolv
	 
	# Apache
	include apache
	include apache::passenger
	 
	#
	# Ldap client
	#
	include c336792::ldapclient

  # 
  # VMWARE Tools
  #
  include vmwaretools
  
  
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
	class { 'mcollective::server': identity => 'puppetmaster.londen01.infra.ntt.eu' }
	
	# Nexus AutoQA
	include nexus::autoqa
	
	#
	# Classes (environment-modules)
	#
	

}

