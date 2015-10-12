node 'evl3301021.eu.verio.net' {
	
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
    # SNMP Service
    #
    
    class { 'snmp':
    	snmpro => "4xAbvJY7",
    	snmpdisks => ["/", "/boot"],
    }
	
	
	# ******************************************************************
	
	# Client Configurations
	include logrotate
	include c336792::pci
	
	# Log configuration	
	include c336792::pci::clientlogs
	
	#
	# Classes (environment-modules)
	#
	
	#
	# Include firewall rules
	#
	include c336792::firewall::pci
	
	# Add more firewall rules to enable the Vuln. Scan Box to access all access within the PCI scope
	@firewall { '400 Vulnbox TCP Incoming':
		proto => 'tcp',
		chain => 'INPUT',
		source => '83.217.239.64/26',
		action => 'accept',		
	}
	@firewall { '400 Vulnbox TCP Outgoing':
		proto => 'tcp',
		chain => 'OUTPUT',
		destination => '83.217.239.64/26',
		action => 'accept',		
	}
	@firewall { '400 Vulnbox UDP Incoming':
		proto => 'udp',
		chain => 'INPUT',
		source => '83.217.239.64/26',
		action => 'accept',		
	}
	@firewall { '400 Vulnbox UDP Outgoing':
		proto => 'udp',
		chain => 'OUTPUT',
		destination => '83.217.239.64/26',
		action => 'accept',		
	}
	@firewall { '400 Vulnbox ICMP Incoming':
		proto => 'icmp',
		chain => 'INPUT',
		source => '83.217.239.64/26',
		action => 'accept',		
	}
	@firewall { '400 Vulnbox ICMP Outgoing':
		proto => 'icmp',
		chain => 'OUTPUT',
		destination => '83.217.239.64/26',
		action => 'accept',		
	}	

}