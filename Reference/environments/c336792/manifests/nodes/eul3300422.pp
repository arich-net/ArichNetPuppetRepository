node 'eul3300422.eu.verio.net' {
	
	# Node Variables
	$my_hostname = "eul3300422"
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
		ssh_pubkeyauthentication => 'yes',
		ssh_x11forwarding => 'no',
		ssh_allowtcpforwarding => 'no',
		ssh_allowagentforwarding => 'no', 
		ssh_clientaliveinterval => '900', 
		ssh_clientalivecountmax => '0',		
	}
	
	class { 'c336792::default':}
	
	#
  # SNMP Service
  #
  
  class { 'snmp':
  	snmpro => "GdP7gtwZ",
  	snmpdisks => ["/", "/usr/local", "/home", "/opt", "/backups"],
  	snmpfile => "pci_servers_snmp.erb",
  }    	

  #
  # Define sudoers for this PCI server
  #
  class { 'sudo': sudoers => "pci_pollers_sudoers.erb"}

	# ******************************************************************
	
	
	# ******************************************************************
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
  
	# Client Configurations
	include logrotate
	include c336792::pci
	
	# Log configuration
	include c336792::pci::clientlogs
	
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
		weekday => tue,
	}
	
	#
	# Include firewall rules
	#
	include c336792::firewall::pci
		
	# Some Nexus Poller Rules 
	
	@firewall { '400 Nexus Poller HTTPS Incoming':
		proto => 'tcp',
		chain => 'INPUT',
		dport => '443',
		action => 'accept',
		state   => ['NEW', 'RELATED', 'ESTABLISHED'],
	}
	@firewall { '400 Nexus Poller HTTPS Outgoing':
		proto => 'tcp',
		chain => 'OUTPUT',
		sport => '443',
		action => 'accept',
		state   => ['RELATED', 'ESTABLISHED'],
	}
	@firewall { '400 Nexus Poller TCP-5432 Incoming':
		proto => 'tcp',
		chain => 'INPUT',
		dport => '5432',
		action => 'accept',
		state   => ['NEW', 'RELATED', 'ESTABLISHED'],
	}
	@firewall { '400 Nexus Poller TCP-5432 Outgoing':
		proto => 'tcp',
		chain => 'OUTPUT',
		sport => '5432',
		action => 'accept',
		state   => ['RELATED', 'ESTABLISHED'],
	}
	@firewall { "400 Nexus Poller SNMP Outgoing":
		proto => 'udp',
		dport => '161',
		chain => 'OUTPUT',
		action => 'accept',		
	}
	@firewall { "400 Nexus Poller SNMP Incoming":
		proto => 'udp',
		sport => '161',
		chain => 'INPUT',
		action => 'accept',		
	}
	@firewall { '400 Nexus Poller TCP-8550 Outgoing':
		proto => 'tcp',
		chain => 'OUTPUT',
		dport => '8550',
		action => 'accept',
		state   => ['NEW', 'RELATED', 'ESTABLISHED'],
	}
	@firewall { '400 Nexus Poller TCP-8550 Incoming':
		proto => 'tcp',
		chain => 'INPUT',
		sport => '8550',
		action => 'accept',
		state   => ['RELATED', 'ESTABLISHED'],
	}
	
	# Ports to monitor
	@firewall { '400 Nexus Poller HTTP Outgoing':
		proto => 'tcp',
		chain => 'OUTPUT',
		dport => '80',
		action => 'accept',
		state   => ['NEW','RELATED', 'ESTABLISHED'],
	}
	@firewall { '400 Nexus Poller HTTP Incoming':
		proto => 'tcp',
		chain => 'INPUT',
		sport => '80',
		action => 'accept',
		state   => ['RELATED', 'ESTABLISHED'],
	}
	@firewall { '400 Nexus Poller RDP Outgoing':
		proto => 'tcp',
		chain => 'OUTPUT',
		dport => '3389',
		action => 'accept',
		state   => ['NEW', 'RELATED', 'ESTABLISHED'],
	}
	@firewall { '400 Nexus Poller RDP Incoming':
		proto => 'tcp',
		chain => 'INPUT',
		sport => '3389',
		action => 'accept',
		state   => ['RELATED', 'ESTABLISHED'],
	}		
	@firewall { '400 Nexus Poller vCenter UM Outgoing':
		proto => 'tcp',
		chain => 'OUTPUT',
		dport => '9084',
		action => 'accept',
		state   => ['NEW','RELATED', 'ESTABLISHED'],
	}
	@firewall { '400 Nexus Poller vCenter UM Incoming':
		proto => 'tcp',
		chain => 'INPUT',
		sport => '9084',
		action => 'accept',
		state   => ['RELATED', 'ESTABLISHED'],
	}
	@firewall { '400 Nexus Poller vCenter SOAP Outgoing':
		proto => 'tcp',
		chain => 'OUTPUT',
		dport => '8084',
		action => 'accept',
		state   => ['NEW','RELATED', 'ESTABLISHED'],
	}
	@firewall { '400 Nexus Poller vCenter SOAP Incoming':
		proto => 'tcp',
		chain => 'INPUT',
		sport => '8084',
		action => 'accept',
		state   => ['RELATED', 'ESTABLISHED'],
	}
	@firewall { '400 Nexus Poller MSSQL Outgoing':
		proto => 'tcp',
		chain => 'OUTPUT',
		dport => '1433',
		action => 'accept',
		state   => ['NEW','RELATED', 'ESTABLISHED'],
	}
	@firewall { '400 Nexus Poller MSSQL Incoming':
		proto => 'tcp',
		chain => 'INPUT',
		sport => '1433',
		action => 'accept',
		state   => ['RELATED', 'ESTABLISHED'],
	}
  @firewall { '400 EPO Console Monitoring Outgoing':
    proto => 'tcp',
    chain => 'OUTPUT',
    dport => '8445',
    action => 'accept',
    state   => ['NEW','RELATED', 'ESTABLISHED'],
  }
  @firewall { '400 EPO Console Monitoring Incoming':
    proto => 'tcp',
    chain => 'INPUT',
    sport => '8445',
    action => 'accept',
    state   => ['RELATED', 'ESTABLISHED'],
  }	
	
	#
	# Classes (environment-modules)
	#
	# ******************************************************************
}