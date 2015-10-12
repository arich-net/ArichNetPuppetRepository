node 'evl3300859.eu.verio.net' {
# Node Variables
	$my_hostname = "evl3300859"
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
    #ssh_enablesftpchrooted => true,
    #ssh_sftpgroup => 'AG_UNIX_USERS',
    #ssh_sftpchrootdirectory => '/sftp/%u',
    ssh_sftpsubsystemcommand => 'usr/lib/openssh/no-sftp-server',
    #ssh_sftpallowtcpforwarding => 'no',
	}
	
	class { 'c336792::default':}
	
  #
  # SNMP Service
  #
  
  class { 'snmp':
  	snmpro => "gz64Rgoy",
  	snmpdisks => ["/", "/boot", "/home", "/quarantine", "/sftp"],
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
  	postfix_myhostname => "evl3300859.eu.verio.net",
    postfix_mynetworks => ['127.0.0.0/8', '213.130.46.253/32'],				
    postfix_append_dot_mydomain => "yes",
    postfix_relayhost => "213.130.46.253",
    postfix_inet_interfaces => "loopback-only",
	}

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
    unlock_time => "300",
    loginexec => "/root/create_sftp.sh",
  }
  	
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
		weekday => wed,
	}

  cron { "clamscan_cron.sh":
    ensure  => present,
    command => "/usr/local/ntte/c336792/scripts/pci_scripts/clamscan_cron.sh >> /var/log/clamav/clamscan.log",
    user => root,    
    minute => '*/5',
  }

  cron { "clean_sftp_dir.sh":
    ensure  => present,
    command => "/usr/local/ntte/c336792/scripts/pci_scripts/clean_sftp_dir.sh",
    user => root,    
    hour => 1,
    minute => 0,
  }   	
	
	#
	# Include firewall rules
	#
	include c336792::firewall::pci
		
	# 
  # VMWARE Tools
  #
  include vmwaretools
  
  # Firewall Rules to enbale File Transfer
  @firewall { '400 File Transfer SFTP Incoming':
    proto => 'tcp',
    chain => 'INPUT',    
    dport => '22222',
    action => 'accept',
    state   => ['NEW', 'RELATED', 'ESTABLISHED'],
  }
  @firewall { '400 File Transfer SFTP Outgoing':
    proto => 'tcp',
    chain => 'OUTPUT',
    sport => '22222',
    action => 'accept',
    state   => ['RELATED', 'ESTABLISHED'],
  }
  @firewall { '401 SSH Outgoing':
    proto => 'tcp',
    chain => 'OUTPUT',    
    dport => '22',
    action => 'accept',
    destination => '192.168.239.96/29',
    state   => ['NEW', 'RELATED', 'ESTABLISHED'],
  }
  @firewall { '401 SSH Incoming':
    proto => 'tcp',
    chain => 'INPUT',
    sport => '23',
    source => '192.168.239.96/29',
    action => 'accept',
    state   => ['RELATED', 'ESTABLISHED'],
  }
  
	#
	# Classes (environment-modules)
	#
	# ******************************************************************
		
}