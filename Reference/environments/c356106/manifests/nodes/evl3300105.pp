node 'evl3300105.eu.verio.net' {	
  
	# Node Variables
	
	# 
	#IP Settings
	#
	  
	#	
	# Users : Local : as per nexus
	#
	
	# Include apt
	include apt
	
	# Include augeas on the node
	include augeas
	
	# Include sysfirewall which will apply on the rest of the modules the correct 
	# firewall rules
	include sysfirewall
	
	# 
	# Classes (core-modules)
	#
	#class { 'core::default':
	#	puppet_environment => 'c356106',
	#	puppet_master => 'puppetmaster-dev.londen01.infra.ntt.eu',         
	#}
	
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
	class { 'c356106::default':}
	
	#
	  # NTP Server Settings
	  #
	  include c356106::ntpservers::pci::server
	  
	  #
	  # SNMP Service
	  #
	  
	  class { 'snmp':
	  	snmpro => "H9gwUQJX",
	  	snmpdisks => ["/", "/boot"],
	  }
	  
	  # Include aliases file
	  include c356106::mailalias::pci
	  
	  #
	  # POSTFIX Service
	  #
	  class { 'postfix':
	    postfix_myhostname => "evl3300857.eu.verio.net",
		  postfix_mynetworks => ['127.0.0.0/8', '213.130.46.253/32'],				
		  postfix_append_dot_mydomain => "yes",
		  postfix_relayhost => "213.130.46.253",
		  postfix_inet_interfaces => "loopback-only",
	  }
	
		#
		# PAM SERVICE
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
  
	  # Hosts allow
	  tcpwrapper::service { 
	    'sendmail': ensure => 'present', src => ['all'];
	  }
	
	 # ******************************************************************	
	 # Client Configurations
	 include logrotate
	 include c356106::pci_lab
		
	 # Log configuration	
	 include c356106::pci_lab::clientlogs
	
	 #
	 # Include firewall rules
	 #
	 include c356106::firewall::pci
	
	 #
	 # CRON entries specific for this node
	 #
	 cron { "UpdatesAvailableCheck.pl":
		  ensure  => present,
		  command => "[ `date +\%d` -ge 8 -a `date +\%d` -le 14 ] && /usr/local/ntte/c356106/scripts/pci_scripts/ubuntu_updates.sh",
		  user => root,
		  hour => 4,
		  minute => 0,
		  monthday => '*',
		  weekday => thu,
 	 }
	
	   
	 # 
	 # VMWARE Tools
	 #
	 include vmwaretools
		
	 #
	 # Classes (environment-modules)
	 #
}