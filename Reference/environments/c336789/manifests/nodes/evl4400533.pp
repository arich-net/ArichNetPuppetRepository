#
# evl4400533
#
node 'evl4400533' {

	class { 'core::default':
		puppet_environment => 'c336789',
	}
	class { 'c336789::default':} 

	case $::datacenter {
		/(?i)(Slough)/: { 
			$ldap1 = "evw3300026.ntteng.ntt.eu" 
			$ldap2 = "evw0300021.ntteng.ntt.eu"
			$proxy_ip = "evl3300858.eu.verio.net"
			$proxy_port = "3128"
			$forwarder_ip = "evl3300860.eu.verio.net"
		}
		default: {
			$ldap1 = "evw0300021.ntteng.ntt.eu"
			$ldap2 = "evw3300026.ntteng.ntt.eu"   
			$proxy_ip = "evl0300858.eu.verio.net"
			$proxy_port = "3128"
			$forwarder_ip = "evl0300860.eu.verio.net"   
		} 
	}	

	#
	# Ldap client
	# 
	ldap::client::login { 'ntteng':
    	ldap_uri => "ldap://${ldap1} ldap://${ldap2}",
		search_base => "dc=ntteng,dc=ntt,dc=eu",
		bind_dn => "cn=NTTEO LDAP Service,cn=Users,dc=ntteng,dc=ntt,dc=eu",
		bind_passwd => "zujs6XUdkF",
	}
	
}
