node 'puppet-client-test-redhat' {
	
	# Node Variables
	$my_hostname = "puppet-client-test-redhat"
	$my_location = "londen01"
	$my_domain = "infra.ntt.eu"
	$my_snmpro = "test_snmpro"
	$my_snmprw = "test_snmprw"
 
	#IP Settings
		include networking
		networking::interfaces::managed_interface{ "eth0":
			ensure   => "present",
			device  => "eth0",
			ipaddr  => "213.130.39.6",
			netmask => "255.255.255.224",
			up  => true,
		}	
		networking::interfaces::managed_interface{ "eth1":
			ensure   => "present",
			device  => "eth1",
			ipaddr  => "192.168.231.201",
			netmask => "255.255.255.0",
			up  => true,
		}


   		networking::routes::managed_route{ "192.168.0.0/16":
		 	ensure   => "present",
       		network => "192.168.0.0",
       		subnet => "255.255.0.0",
       		gateway => "192.168.231.254",
       		interface => "eth1",
   }
   
      		  networking::routes::managed_route{ "8.8.8.8/32":
		 ensure   => "present",
       network => "8.8.8.8",
       subnet => "255.255.255.255",
       gateway => "213.130.39.30",
       interface => "eth0",
   }

	#Users
 
	# 
	# Classes (core-modules)
	#
	include base_class # basenode class
	include location_londen01
	include hosts
	include core::hosts::backupservers
	include motd
	include ntp
	include sudo
	include subversion
	
#	hosts::add::record { 'testing':
#		hostname => 'testing.domain.com',
#		hostaliases => 'testing',
#		ip => '4.4.4.4',
#	}
	
	class { 'snmp': snmpro => "$my_snmpro",}	
	class { 'ssh::server': port => '22', usepam => 'yes', } 
	
	resolver::resolv_conf { 'ntte_resolv':
		domainname  => "londen01.infra.ntt.eu",
		searchpath  => ['ntteng.ntt.eu', 'eu.verio.net'],
		nameservers => ['192.168.231.26', '192.168.231.8', '192.168.77.46'],
	}
	
	#
	# Apache
	#
	include apache
	class { 'apache::php':
		ensure => 'present',
	}
	class { 'apache::ssl':
		ensure => 'present',
	}  
	
	#
	# Apache VHosts
	#
	apache::vhost { 'site.name.fqdn':
     priority => '20',
     port => '80',
     docroot => '/path/to/docroot',
    }
	
	#
	# Ldap client
	#
	ldap::client::login { 'ntteng':
		ldap_uri => 'ldap://evw0300021.ntteng.ntt.eu ldap://evw3300026.ntteng.ntt.eu', 
		search_base => 'dc=ntteng,dc=ntt,dc=eu', 
		bind_dn => 'cn=NTTEO LDAP Service,cn=Users,dc=ntteng,dc=ntt,dc=eu', 
		bind_passwd => 'zujs6XUdkF',
	}
	
	#
	# Puppet
	#
	class { 'puppet::client': 
		server => 'puppetmaster.londen01.oob.infra.ntt.eu',
		environment => 'c336792',
		certname => 'puppet-client-test-redhat',
		role => 'client', # master,client,puppeteer; determines puppet.conf
		report => 'false',
		}

	# Splunk
	class { 'splunk::indexer': }
	splunk::authldap { 'ntteng':
		host => 'evw3300026.ntteng.ntt.eu',
		port => '636',
		search_base => 'ou=NTT EO,dc=ntteng,dc=ntt,dc=eu', 
		bind_dn => 'cn=NTTEO LDAP Service,cn=Users,dc=ntteng,dc=ntt,dc=eu', 
		bind_passwd => '$1$brjHS+nb3AyjAlE=',
	}
	class { 'c336792::splunkmonitors::global': ensure => 'present', }
	splunk::define::manageuser { "mparry": ensure=> 'present'}

	# Mcollective
	class { 'mcollective::server': stomphost => '192.168.231.200' }

  # 
  # VMWARE Tools
  #
  include vmwaretools

	#	
	# Users
	#
	class { 'c336792::users::root': 
		pass => '$1$0x7ZDol9$/O0J2R/DojEcTArRtFeFY.',
	}
	class { 'c336792::users::nttuser':
		ensure => 'present', 
		pass => '$1$HdTael43$RCi5gkB4enzoC8Mn4X3EI1',
	}
	class { 'c336792::users::custuser':
		ensure => 'present', 
		pass => '$1$HdTael43$RCi5gkB4enzoC8Mn4X3EI1',
	}
	
	#
	# Classes (environment-modules)
	#
	
	

}

