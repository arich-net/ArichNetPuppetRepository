node 'evw3300023.oob.eu.verio.net' {
	
	# Node Variables
	$my_hostname = "evw3300023"
	$my_location = "londen01"
	$my_domain = "eu.verio.net"
	$my_snmpro = "testingro"
	$my_snmprw = "testingrw"
 
	# 
	#IP Settings
	#
    
	#	
	# Users : Local : as per nexus
	#
	
	# 
	# Classes (core-modules)
	#
	 
	#
	# Ldap client
	# 
	
	#
	# Puppet
	#
	
	
	#
	# Classes (environment-modules)
	#
	
	file { 'c:/somefile.txt':
  		ensure  => 'file',
  		content => 'hello testing',
	}


}

