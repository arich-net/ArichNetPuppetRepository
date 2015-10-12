node 'evl3300857.eu.verio.net' {
	
	# Node Variables
	
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
  # NTP Server Settings
  #
  include c336792::ntpservers::pci::server
    
  #
  # SNMP Service
  #
    
  class { 'snmp':
  	snmpro => "HfSuWRL8",
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
   	postfix_myhostname => "evl3300857.eu.verio.net",
		postfix_mynetworks => ['127.0.0.0/8', '213.130.46.253/32'],				
		postfix_append_dot_mydomain => "yes",
		postfix_relayhost => "213.130.46.253",
		postfix_inet_interfaces => "loopback-only",
	}
	
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
	include c336792::pci::clientlogs
	
	#
	# Include firewall rules
	#
	include c336792::firewall::pci
	
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
	# NTP Monitoring
	#
	# Execute the script every hour
	cron { "pci_ntp_monitoring.sh":
    ensure  => present,
    command => "/usr/local/ntte/c336792/scripts/pci_scripts/pci_ntp_monitoring.sh 2>&1 > /dev/null",
    user => root,
    hour => '*',
    minute => 30,       
  }
  # Rotate the log files this script will produce
  logrotate::file { 'ntpmon_log':
    log        => [ '/var/log/ntpmon.log' ],
    options    => [ 'daily', 'compress', 'rotate 10', 'missingok' ]
  }
	# Send this log information to Splunk
	splunk::config::client::monitor { "/var/log/ntpmon*": 
	  type => 'log', 
	  index => 'pci',
	  sourcetype => 'PCI-NTP-Monitor',
  }
	   
  # 
  # VMWARE Tools
  #
  include vmwaretools
		
	#
	# Classes (environment-modules)
	#
	
	
}