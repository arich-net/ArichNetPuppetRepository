# Class: ssh::pci
#
# Used for setting default PCI hardening standards for c356106 environment
# Specific for applying to standard builds and to maintain these standards overtime
#
#	c356106::pci_lab::clientlogs
#		Used for the PCI splunk clients, to configure log monitors
#
#	c356106::pci_lab::serverlogs
#		Used for the PCI splunk forwarder configuration 
#
# Parameters:
#
# Actions:
#
# Requires:
#
# Sample Usage:
#	include c356106::pci_lab
#	include c356106::pci_lab::clientlogs
#
# [Remember: No empty lines between comments and class definition]
class c356106::pci_lab () {	
	#
	# Verifying the DC of the host 
	#
	case $::datacenter {
		 /(?i)(Slough)/: { 
			$ldap1 = "83.231.197.15"
			$ldap2 = "83.231.197.18"        			
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
	#include apt
	#apt::conf {'90httpproxy':
	#	ensure => 'present',
	#	content => "Acquire::http::Proxy \"http://${proxy_ip}:${proxy_port}\";\n"
	#}
	
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
                search_base => "dc=ntteng2,dc=ntt,dc=eu",
                bind_dn => "CN=NTTEO LDAP Service,OU=NTTEO Services OU,OU=NTT EO,DC=ntteng2,DC=ntt,DC=eu",
                bind_passwd => "Barcelona2012",
                cert => 'puppet:///files-environment/c356106/files/ldap/ntteng2ca.pem'
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
	
	case $::operatingsystem {
	  /Debian|Ubuntu/: {
	    # Perl libraries
      package { ["libconfig-simple-perl", "liblog-log4perl-perl"]:
        ensure => latest,
      }
    
      # Package user for sending mails for Updates and open tickets to Nexus
      package { "mailutils":
        ensure => latest,	    
	    }
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
	
	# Protecting local users accounts 
	group { 'nttuser':
			ensure => present;
	}
	user { 'nttuser':
    ensure => 'present',
    groups => ['nttuser'],
    membership => inclusive,
    password_max_age => '60',
    password_min_age => '1',
	}
	user { 'root':
	  ensure => 'present',
    password_max_age => '60',
    password_min_age => '1',	  
	}
	user { 'splunk':	  
    shell => '/dev/null',	  	  
	}
	
	# Protect local users on each system
	
	
	class clientlogs() {
		#
		# Splunk
		#
		class { 'splunk::client':
			indexer => "$c356106::pci_lab::forwarder_ip",
		}
			
		include c356106::splunkmonitors::pci		    
	}	
		
}