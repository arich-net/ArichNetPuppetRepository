node 'puppet-client-test' {
	
	# Node Variables
	$my_hostname = "puppet-client-test"
	$my_location = "londen01"
	$my_domain = "infra.ntt.eu"
	$my_snmpro = "test_snmpro"
	$my_snmprw = "test_snmprw"
 
	#IP Settings
		include networking
		networking::interfaces::managed_interface{ "eth2":
			ensure   => "present",
			device  => "eth2",
			ipaddr  => "192.168.231.200",
			netmask => "255.255.255.0",
			#hwaddr  => "00:50:56:a2:07:09",
			up  => true,
		}
		networking::interfaces::managed_interface{ "eth3":
			ensure   => "present",
			device  => "eth3",
			ipaddr  => "213.130.39.5",
			netmask => "255.255.255.224",
			#hwaddr  => "00:50:56:a2:07:08",
			up  => true,
		}
		
		  networking::routes::managed_route{ "192.168.0.0/16":
		 ensure   => "present",
       network => "192.168.0.0",
       subnet => "255.255.0.0",
       gateway => "192.168.231.254",
       interface => "eth2",
   }
   
   		  networking::routes::managed_route{ "8.8.8.8/32":
		 ensure   => "present",
       network => "8.8.8.8",
       subnet => "255.255.255.255",
       gateway => "213.130.39.30",
       interface => "eth3",
   }
		

	#Users
 
	# 
	# Classes (core-modules)
	#
	include base_class # basenode class
	
	class { 'core::default':
		puppet_environment => 'c336792',
		puppet_certname => 'puppet-client-test',
		puppet_report => false,
	}
	
	class { 'c336792::default':}
	
	include hosts
	include core::hosts::backupservers
	include motd
	include ntp
	include sudo
	include subversion
	
	class { 'mysql':}
	class { 'mysql::server':}
	class { 'mysql::ruby':}
	
	class { 'puppet-dashboard': }
	
	mysql::db { 'mytestdb':
		user => 'mparry',
        password => 'foobar',
        grant => ['insert_priv'],
	}
	
	
	include apt 
	
	tcpwrapper::service { 'testservice':
		ensure => 'present',
		src => ['*.domain.com', '127.0.0.1', '192.168.1.1/255.255.255.0'],
	}

	#hosts::add::record { 'testing':
	#	hostname => 'testing.domain.com',
	#	hostaliases => 'testing',
	#	ip => '4.4.4.4',
	#}
	
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
  # VMWARE Tools
  #
  include vmwaretools
  
  
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
		#cert => 'puppet:///files-environment/c336792/files/ldap/nttengca.pem'
	}
	
	# Splunk
	class { 'splunk::client':
		indexer => '192.168.231.18',
		indexerport => '9997',
	}
	# Splunk monitors
	class { 'c336792::splunkmonitors::global': ensure => 'present', }


	class { 'activemq': }
	# Mcollective
	class { 'mcollective::client': stomphost => '192.168.231.200' }

	#	
	# Users
	#	#include role_unix_staging # Include role
	
	#
	# Classes (environment-modules) - TEST
	#
	include djbdns::dnscache
	include c336792::dnscache
	

}

