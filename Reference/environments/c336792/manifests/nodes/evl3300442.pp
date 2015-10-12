node 'evl3300442.londen01.infra.ntt.eu' {
	
	# Node Variables
	$my_hostname = "evl3300442"
	$my_location = "londen01"
	$my_domain = "londen01.infra.ntt.eu"
	$my_snmpro = "vX5JiXhH"
	$my_snmprw = "vX5JiXhHvX5JiXhH"
 
 	#
	#IP Settings
	#
	networking::interfaces::managed_interface{ "eth0":
		ensure   => "present",
		device  => "eth0",
		ipaddr  => "213.130.39.1",
		netmask => "255.255.255.224",
		up  => true,
	}
	networking::interfaces::managed_interface{ "eth1":
		ensure   => "present",
		device  => "eth1",
		ipaddr  => "192.168.231.101",
		netmask => "255.255.255.0",
		up  => true,
	}
		
	#	
	# Users : Local : as per nexus
	#
	class { 'c336792::users::root': 
		pass => '$6$ese.OzQ0$DY9pWn8GAK4sVMGQfTl2/CLzFziKp/FeYD9GqHSa2d0wilaZRd/lwm5PgAkvp6oV7k0sPgmbFFgAVgIm0IZ9t1',
	}
	class { 'c336792::users::nttuser': 
		pass => '$6$QUhNZgHD$yDAGz.c8Jal0b.FcqFupdJCLQTCYdKU4MSqs57SXSQ7fMv8bHgPWByvBPzofnyCX.4ZQHkCzW0iodPGSW7Jvk1',
	}
	class { 'c336792::users::custuser': 
		pass => '$6$8.93FcIW$3js8.hbOVeyAgXOLCL7iATWcMQJEtnx3zdXNNV95CnnJx6VYhZrZugpH00KSuUgf7qHJXXAn3mMz3nLkxh5Y50',
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
		puppet_role => 'puppeteer'
	}
	class { 'c336792::default': }
	class { 'c336792_sysapi': }
	class { 'c336792_sysengbot': }
	
	include hosts
	include motd
	include ntp
	class { 'sudo': sudoers => "evl3300422_sudoers.erb"}
	include subversion
	class { 'apt': }
	class { 'snmp': snmpro => "$my_snmpro",}
	class { 'ssh::server': ssh_usepam => 'yes', }
	resolver::resolv_conf { 'ntte_resolv':
		domainname  => "londen01.infra.ntt.eu",
		searchpath  => ['ntteng.ntt.eu', 'eu.verio.net'],
		nameservers => ['192.168.231.26', '192.168.231.8', '192.168.77.46'],
	}
	
	# Apache
	include apache
	include apache::passenger
	
	class { 'puppet_dashboard':
		dashboard_dbpassword => 'HU76we32',
		dashboard_inventory => 'true'
	}

  class {'netbackup::client': }
  
  # 
  # VMWARE Tools
  #
  include vmwaretools
  
	#
	# Ldap client 
	#
	include c336792::ldapclient
	
	#
	# Puppeteer
	#
	class { 'puppet::puppeteer':
		puppet_storeconfigs => 'true',
		puppet_storeconfigs_dbpasswd => 'K6RcytkP',
		puppet_passenger => true,
		puppet_is_ca_server => true,
	}
	include foreman
	
	class { 'hiera':}
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
	class { 'mcollective::client': }
	class { 'mcollective::server': identity => 'puppeteer.londen01.infra.ntt.eu' }
	mcollective::plugin {"puppetca": type => "agent",}
		
	#
	# Classes (environment-modules)
	#
	
	

}

