node 'evl4400675.eu.verio.net' {
	case $::datacenter {
		 /(?i)(Slough)/: { 
			$ldap1 = "evw3300026.ntteng.ntt.eu" 
			$ldap2 = "evw0300021.ntteng.ntt.eu"
		}
		default: {
			$ldap1 = "evw0300021.ntteng.ntt.eu"
			$ldap2 = "evw3300026.ntteng.ntt.eu" 	
		}	
	}

	#
	# SSH
	#
	class { 'ssh::server': 
		ssh_usepam => 'yes',
	}

	#
	# Host File
	#
	include hosts
	include core::hosts::nttenghosts

	#
	# Sudoers
	#	
	class { 'sudo': sudoers => "evl4400675_sudoers.erb"}
	
	#
	# Ldap client
	# 
	ldap::client::login { 'ntteng':
                ldap_uri => "ldap://${ldap1} ldap://${ldap2}",
                search_base => "dc=ntteng,dc=ntt,dc=eu",
                bind_dn => "cn=NTTEO LDAP Service,cn=Users,dc=ntteng,dc=ntt,dc=eu",
                bind_passwd => "zujs6XUdkF",
	}

	package { ["python-simplejson", "python-httplib2"]:
        ensure => latest,
    }

}

