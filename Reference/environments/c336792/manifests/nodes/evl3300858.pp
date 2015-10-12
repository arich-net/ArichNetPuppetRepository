node 'evl3300858.eu.verio.net' {
	
	# Node Variables
	$my_hostname = "evl3300858"
	$my_location = "londen01"
	$my_domain = "londen01.infra.ntt.eu"
	
	# 
	#IP Settings
	#
    
	#	
	# Users : Local : as per nexus
	#
	
	# Include sysfirewall which will apply on the rest of the modules the correct 
	# firewall rules
	include sysfirewall
	
	# 
	# Classes (core-modules)
	#
	class { 'core::default':
		puppet_environment => 'c336792',
	}
		
	# ******************************************************************
	# SERVICES OF THIS NODE
	
	#
	# SSH
	#
	class { 'ssh::server': 
		ssh_usepam => 'yes',
		ssh_pubkeyauthentication => 'no',
		ssh_x11forwarding => 'no',
		ssh_allowtcpforwarding => 'no',
		ssh_allowagentforwarding => 'no', 
		ssh_clientaliveinterval => '900', 
		ssh_clientalivecountmax => '0',		
	}
	class { 'c336792::default':}
	
	#
	# Squid
	#
 	class {'squid':    	
  	squid_emulate_httpd_log => 'on',
  	squid_cache_size => '256',
  	squid_port => '3128',
  	squid_auth_enabled_type => 'ldap',
    squid_ldap_auth_binddn => 'squid.service@ntteng.ntt.eu',
    squid_ldap_auth_bindpwd => 'h4bZVwEU',
    squid_ldap_auth_ldaphost => 'evw3300026',
    squid_ldap_auth_ldapport => '389',
    squid_ldap_auth_ldapbasedn => 'OU=NTT EO,DC=ntteng,DC=ntt,DC=eu',
    squid_ldap_auth_ldaprealm => 'NTTENG Userid without the domain',
    squid_ldap_auth_groups => {
		1 => { 'groupname' => 'Engineering', 'ldapgroupname' => 'AG_PCI_ENG' },
  		2 => { 'groupname' => 'CSC_Level1', 'ldapgroupname' => 'AG_PCI_CSC_L1' },
  		3 => { 'groupname' => 'CSC_Level2', 'ldapgroupname' => 'AG_PCI_CSC_L2' },
  		4 => { 'groupname' => 'Deployment', 'ldapgroupname' => 'AG_PCI_COE' },
  		5 => { 'groupname' => 'Atlas_Engineering', 'ldapgroupname' => 'AG_PCI_APPMAN_ENG' },
  		6 => { 'groupname' => 'Atlas_Support', 'ldapgroupname' => 'AG_PCI_APPMAN_CSC' },
    },
  }
    
  include c336792::squid::pci
    
  #
  # SNMP Service
  #
  
  class { 'snmp':
  	snmpro => "QFMHW96f",
  	snmpdisks => ["/", "/boot"],
  	snmpfile => "pci_servers_snmp.erb",
  }
  
  #
  # Define sudoers for this PCI server
  #
  class { 'sudo': sudoers => "pci_servers_sudoers.erb"}
  
  # Include aliases file
  include c336792::mailalias::pci
  
  #
  # POSTFIX Service
  #
  class { 'postfix':
  	postfix_myhostname => "evl3300858.eu.verio.net",
	postfix_mynetworks => ['127.0.0.0/8', '213.130.46.253/32'],				
	postfix_append_dot_mydomain => "yes",
	postfix_relayhost => "213.130.46.253",
	postfix_inet_interfaces => "loopback-only",
	}
	
	# 
	# VMWARE Tools
	#
	include vmwaretools
      
	# ******************************************************************
	# Client Configurations
  #
  # Include PCI local Password Policies
  #
  class {'pam::passwd':
    max_days => "60", 
    min_days => "1",
    warn_age => "7", 
    min_length => "7",
  } 
  
  class {'pam::commonpassword':
    enforcenment => "yes",
    min_length => "7",
    upper_case => "1",
    lower_case => "1",
    digits => "1",
  }
  
  class {'pam::login':
    enforcenment => "yes",
    fail_delay => "5000000",
    lockout_attempts => "6",
    unlock_time => "300"
  }
  	
	include logrotate
	include c336792::pci
	
	# Log configuration
	include logrotate
	include c336792::pci::clientlogs
	
	# Splunk
	splunk::config::client::monitor { "/var/log/squid/access*": type => 'log', index =>'pci', sourcetype => 'squid_logs' }
	splunk::config::client::monitor { "/var/log/squid/cache*": type => 'log', index =>'pci', sourcetype => 'squid_cache_logs'  }
	splunk::config::client::monitor { "/var/log/squid/store*": type => 'log', index =>'pci', sourcetype => 'squid_store_logs'  }

	#
	# NTP Client
	#
	include c336792::ntpservers::pci
	
	#
	# CRON entries specific for this node
	#
	cron { "UpdatesAvailableCheck.pl":
		ensure  => present,
		command => "[ `date +\%d` -ge 8 -a `date +\%d` -le 14 ] && /usr/local/ntte/c336792/scripts/pci_scripts/ubuntu_updates.sh",
		user => root,
		hour => 4,
		minute => 0,
		monthday => '*',
		weekday => thu,
	}
		
	#
	# Include firewall rules
	#
	include c336792::firewall::pci
	
	# Specific firewall rules for this server
	# AV Server rules
	@firewall { '400 AV Updates TCP Outgoing':
		proto => 'tcp',
		dport => '2221',
		chain => 'OUTPUT',
		action => 'accept',
		state   => ['NEW', 'RELATED', 'ESTABLISHED'],
	}
	@firewall { '400 AV Updates TCP Incoming':
		proto => 'tcp',
		sport => '2221',
		chain => 'INPUT',
		action => 'accept',
		state   => ['RELATED', 'ESTABLISHED'],
	}
	
	# GPG Key Servers			
	@firewall { '400 GPG Keys TCP Outgoing':
		proto => 'tcp',
		dport => '11371',
		chain => 'OUTPUT',
		action => 'accept',
		state   => ['NEW', 'RELATED', 'ESTABLISHED'],
	}
	@firewall { '400 GPG Keys TCP Incoming':
		proto => 'tcp',
		sport => '11371',
		chain => 'INPUT',
		action => 'accept',
		state   => ['RELATED', 'ESTABLISHED'],
	}
	
	# Nessus Management
	@firewall { '400 Nessus Management Outgoing':
    proto => 'tcp',
    chain => 'OUTPUT',
    dport => '8834',
    action => 'accept',
    state   => ['NEW','RELATED', 'ESTABLISHED'],
  }
  @firewall { '400 Nessus Management Incoming':
    proto => 'tcp',
    chain => 'INPUT',
    sport => '8834',
    action => 'accept',
    state   => ['RELATED', 'ESTABLISHED'],
  }
	#
	# Classes (environment-modules)
	#
	# ******************************************************************
}