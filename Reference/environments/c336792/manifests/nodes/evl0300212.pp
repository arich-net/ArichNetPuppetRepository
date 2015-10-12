node 'evl0300212.frnkge05.infra.ntt.eu' {
	
	# Node Variables
	$my_hostname = "evl0300212"
	$my_location = "frnkge05"
	$my_domain = "frnkge05.infra.ntt.eu"
	$my_snmpro = "8GNPLzMy"
	$my_snmprw = "8GNPLzMy8GNPLzMy"
 
	# 
	#IP Settings
	#
	networking::interfaces::managed_interface{ "eth0":
		ensure   => "present",
		device  => "eth0",
		ipaddr  => "91.186.178.50",
		netmask => "255.255.255.224",
		up  => true,
	}
	networking::interfaces::managed_interface{ "eth1":
		ensure   => "present",
		device  => "eth1",
		ipaddr  => "192.168.178.50",
		netmask => "255.255.255.224",
		up  => true,
	}
    
	#	
	# Users : Local : as per nexus
	#
	class { 'c336792::users::root': 
		pass => '$6$7tNdLXMJ$VB0iWgCDhT76fbWkLB8l7JTeo2T3YyQh1zZUsUlJU.8J8tgQMZB3HeplIBRzKa3GxZBUOswIN6zcMxXSt/8w2/',
	}
	class { 'c336792::users::nttuser': 
		pass => '$6$40ob/0wI$Geh0pEDZXrJ6Y4NYG7sW2LDGJXwiOdZTtj3owSvJYiZoZUhfLvPyBglogF7fKJustzbzlFCpAS9yUeNxqCN0m/',
	}
	class { 'c336792::users::custuser': 
		pass => '$6$HR3tFtYZ$DdxGdDkibP7QwcC4EUp/m1NvxbKDFPuGM1w4wVu.5uuPMO73PNfxvH9/7jd.8i3vTG96hcJtL7rXzPNXW7nuU0',
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
		puppet_certname => 'puppetmaster.frnkge05.infra.ntt.eu',
		puppet_role => 'master'
	}
	class { 'c336792::default': }
	include hosts
	include motd
	include ntp
	class { 'sudo': sudoers => "puppetmasters_sudoers.erb"}
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
	class { 'mcollective::server': identity => 'puppetmaster.frnkge05.infra.ntt.eu' }
	
	#
	# Classes (environment-modules)
	#
	

}

