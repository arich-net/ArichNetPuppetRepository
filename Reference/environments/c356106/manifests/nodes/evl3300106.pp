node 'evl3300106.eu.verio.net' {	
  
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

	include c356106::pci_lab
}
