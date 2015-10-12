node 'evl3300860.eu.verio.net' {
	
	$my_hostname = "evl3300860"
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
  	snmpro => "i77CVNWL",
  	snmpdisks => ["/", "/boot", "/home", "/xceedium"],
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
    postfix_myhostname => "evl3300860.eu.verio.net",
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
	
	
	class { 'splunk::forwarder':
    indexer => 'evl3300244.eu.verio.net',
    tcpinputindex => 'pci',
    udpinputindex => 'pci',
    ssl => true,
		sslrootca => "cacert.pem",
		sslservercert => "evl3300860Cert.pem",
		sslpassphrase => '$1$1SjGDfWFL1cl'
	}
	
	#
	# NTP Client
	#
	include c336792::ntpservers::pci
	
	#
	# CRON entries specific for this node
	#
	cron { "ntt_pci_backup_xceedium.sh":
		ensure  => present,
		command => "/usr/local/ntte/c336792/scripts/pci_scripts/ntt_pci_backup_xceedium.sh >> /var/log/xceedium_backup.log",
		user => root,
		hour => 0,
		minute => 0,
	}
	
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
	# Logrotate entries for this node
	#
	logrotate::file { 'xceedium_backup':
		log        => [ '/var/log/xceedium_backup.log' ],
		options    => [ 'daily', 'compress', 'rotate 10', 'missingok' ]
	}
	
	#
	# Splunk monitors specific for this node
	#
	# log monitors
    splunk::config::forwarder::monitor { "/var/log/messages*": type => 'log', index => 'pci'  }
	splunk::config::forwarder::monitor { "/var/log/syslog*": type => 'log', index => 'pci'  }
	splunk::config::forwarder::monitor { "/var/log/auth*": type => 'log', index => 'pci'  }
	splunk::config::forwarder::monitor { "/var/log/daemon*": type => 'log', index => 'pci'  }
		
	splunk::config::forwarder::monitor { "/var/log/puppet/puppet*": type => 'log', index => 'pci' }
	splunk::config::forwarder::monitor { "/var/log/clamav/clamav*": type => 'log', index => 'pci' }
	splunk::config::forwarder::monitor { "/var/log/clamav/freshclam*": type => 'log', index => 'pci' }
		
	splunk::config::forwarder::monitor { "/var/log/pci_cis*": type => 'log', index => 'pci' }
	splunk::config::forwarder::monitor { "/var/log/xceedium_backup*": type => 'log', index => 'pci'  }
	splunk::config::forwarder::monitor { "/var/log/clamav/clamscan*": type => 'log', index => 'pci', sourcetype => 'clamscan-logs' }	
		
	# fschange monitors
	splunk::config::forwarder::monitor { "/bin": type => 'file', index => '_audit', signedaudit => false }
	splunk::config::forwarder::monitor { "/sbin": type => 'file', index => '_audit', signedaudit => false }
	splunk::config::forwarder::monitor { "/usr/bin": type => 'file', index => '_audit', signedaudit => false }
	splunk::config::forwarder::monitor { "/usr/sbin": type => 'file', index => '_audit', signedaudit => false }
	splunk::config::forwarder::monitor { "/usr/local/bin": type => 'file', index => '_audit', signedaudit => false }
	splunk::config::forwarder::monitor { "/etc": type => 'file', index => '_audit', signedaudit => false }
	
	
	#
	# Include firewall rules
	#
	include c336792::firewall::pci
	
	# Add more firewall rules to enable Xceedium use NFS with this server
	@firewall { '400 Xceedium NFS TCP Incoming':
		proto => 'tcp',
		chain => 'INPUT',
		source => '83.217.239.88/29',
		action => 'accept',
		state   => ['NEW', 'RELATED', 'ESTABLISHED'],
	}
	@firewall { '400 Xceedium NFS TCP Outgoing':
		proto => 'tcp',
		chain => 'OUTPUT',
		destination => '83.217.239.88/29',
		action => 'accept',
		state   => ['RELATED', 'ESTABLISHED'],
	}	
	@firewall { '400 Xceedium NFS UDP Incoming':
		proto => 'udp',
		chain => 'INPUT',
		source => '83.217.239.88/29',
		action => 'accept',		
	}
	@firewall { '400 Xceedium NFS UDP Outgoing':
		proto => 'udp',
		chain => 'OUTPUT',
		destination => '83.217.239.88/29',
		action => 'accept',		
	}		
		
	
	#
	# Classes (environment-modules)
	#
	# ******************************************************************
	
}