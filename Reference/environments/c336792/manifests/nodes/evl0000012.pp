node 'evl0000012.eu.verio.net' {
	
	# Node Variables
	
	# 
	#IP Settings
	#
    
	#	
	# Users : Local : as per nexus
	#
	
	# 
	# Classes (core-modules)
	#
	class { 'core::default':
		puppet_environment => 'c336792',
	}
	class { 'c336792::default':} 
	class { 'apt': }
	
	class { 'postfix':
		postfix_myhostname => 'man0.eu.verio.net',
		postfix_mynetworks => ['10.0.0.0/8', '62.73.160.0/19', 
		                       '62.96.77.242/32', '81.19.96.0/20', 
		                       '81.20.64.0/20', '81.25.192.0/20',
		                       '81.93.160.0/19', '81.93.208.0/20', 
		                       '82.112.96.0/19', '83.217.224.0/19',
		                       '83.231.128.0/17', '91.186.160.0/19', 
		                       '127.0.0.0/8', '128.121.13.76/32', 
		                       '128.121.13.77/32', '128.241.22.124/32', 
		                       '128.241.22.125/32', '128.242.96.0/24',
		                       '129.250.160.98/32', '157.238.223.132/32', 
		                       '157.238.223.133/32', '168.143.176.64/27', 
		                       '192.168.0.0/16', '212.119.0.0/19', 
		                       '213.130.32.0/19', '213.198.0.0/17', 
		                       '218.213.89.80/28', '128.242.115.80/29', 
		                       '128.242.115.0/27', '128.242.115.88/29', 
		                       '128.242.115.96/27', '5.158.212.0/24'],
		postfix_messagesizelimit => '20480000',
		#postfix_ipblacklist => ['213.198.55.36', '213.130.46.227'],
		postfix_ipblacklist => ['81.93.221.227', '81.19.100.50', '81.19.100.49', '83.231.143.79'],
		postfix_smtpd_client_connection_count_limit => '10',
		postfix_smtpd_client_connection_rate_limit => '60',
		#postfix_anvil_rate_time_unit => '1h',	
	}
		
	#class { 'apache': }
	#apache::vhost { 'cvsweb':
	#	port => '443',
	#	template => 'cvsweb',
	#}
	
	#
	# Ldap client
	# 
	
	#
	# Puppet
	#
	
	# Mcollective
	class { 'mcollective::server': }
	
	
	#
	# Classes (environment-modules)
	#
	
	#
	# Include NTTE Scripts
	#
	include c336792::nttescripts	
}

