# Class: ssh::pci
#
# Used for setting default PCI hardening standards for c356106 environment
# Specific for applying to standard builds and to maintain these standards overtime
#
#	c356106::pci::clientlogs
#		Used for the PCI splunk clients, to configure log monitors
#
#	c356106::pci::serverlogs
#		Used for the PCI splunk forwarder configuration 
#
# Parameters:
#
# Actions:
#
# Requires:
#
# Sample Usage:
#	include c356106::pci
#	include c356106::pci::clientlogs
#
# [Remember: No empty lines between comments and class definition]
class c356106::pci () {	
	#
	# Verifying the DC of the host 
	#
	case $::datacenter {
		 /(?i)(Slough)/: { 
			$ldap1 = "evw3300026.ntteng.ntt.eu" 
			$ldap2 = "evw0300021.ntteng.ntt.eu"
			$proxy_ip = "evl3300858.eu.verio.net"
			$proxy_port = "3128"
			$forwarder_ip = "evl3300860.eu.verio.net"
		}
		default: {
			$ldap1 = "evw0300021.ntteng.ntt.eu"
			$ldap2 = "evw3300026.ntteng.ntt.eu" 	
			$proxy_ip = "evl0300858.eu.verio.net"
			$proxy_port = "3128"
			$forwarder_ip = "evl0300860.eu.verio.net"		
		}	
	}
	
	#
	# APT with proxy definitions
	#
	include apt
	apt::conf {'90httpproxy':
		ensure => 'present',
		content => "Acquire::http::Proxy \"http://${proxy_ip}:${proxy_port}\";\n"
	}
	
	#
	# Host File
	#
	include hosts
	include core::hosts::nttenghosts	
	
	#
	# Ldap client
	# 
	ldap::client::login { 'ntteng':
                ldap_uri => "ldap://${ldap1} ldap://${ldap2}",
                search_base => "dc=ntteng,dc=ntt,dc=eu",
                bind_dn => "cn=NTTEO LDAP Service,cn=Users,dc=ntteng,dc=ntt,dc=eu",
                bind_passwd => "zujs6XUdkF",
	}
	
	    
    #
	# Inlcude clamav for antivirus
	# with defaul daemon mode
	#
	class { 'clamav':
		clamav_cron_enable => true,
		clamav_proxy_server => "$proxy_ip",
		clamav_proxy_port => "$proxy_port",
		clamav_cron_command => "/usr/local/ntte/c356106/scripts/pci_scripts/clamscan_script.sh >> /var/log/clamav/clamscan.log",
	}
	
	# Mcollective
	# class { 'mcollective::server': }
	
	
	#
	# Include some Perl libraries
	#
	
	if ($operatingsystem == debian) or ($operatingsystem == ubuntu) {
		
		package { "libconfig-simple-perl":
			ensure => latest,
		}

		package { "liblog-log4perl-perl":
			ensure => latest,
		}
		
		# Package user for sending mails for Updates and open tickets to Nexus
		package { "mailutils":
			ensure => latest,
		}
	}
	
	#
	# Include some cron and script definitions
	#
	
	include c356106::nttescripts::pci
	
	#
	# We need to ensure the existence of a directory to store 
	# configurations/templates of CIS script and updates
	#
	file { "/etc/NTT/cis_templates":
    	ensure => "directory",
    	owner  => "root",
    	group  => "root",
    	mode   => 750,
	}
	
	file { "/etc/NTT/updates":
    	ensure => "directory",
    	owner  => "root",
    	group  => "root",
    	mode   => 750,
	}
	
	# To store update logs
	file { "/var/log/updates":
    	ensure => "directory",
    	owner  => "root",
    	group  => "root",
    	mode   => 750,
	}
	
	# Soft links needed for PCI systems
	file { "/usr/local/bin/update-configuration.sh": 
		ensure => link, 
		target => "/usr/local/ntte/c356106/scripts/pci_scripts/update-configuration.sh", 
	}
	
	
	#
	# Include PCI logrotate definitions
	#
		
	include c356106::logrotate::pci
	
	# ensure that the user is not part of adm group
	group {
		'nttuser':
			ensure => present;
	}
	user {
    	nttuser:
        	ensure => 'present',
        	groups     => ['nttuser'],
        	membership => inclusive
	}
	
	
	class clientlogs() {
		#
		# Splunk
		#
		class { 'splunk::client':
			indexer => "$c356106::pci::forwarder_ip",
		}
			
		include c356106::splunkmonitors::pci		    
	}	
		
}