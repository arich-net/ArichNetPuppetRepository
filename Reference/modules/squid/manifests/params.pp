# Class: squid::params
#
# Parameters:
#
# Actions:
#
# Requires:
#
# Sample Usage:
#
# [Remember: No empty lines between comments and class definition]
class squid::params  {	
	
	$config_path = $::lsbdistcodename ? {
		'precise' => "/etc/squid3",
		default => "/etc/squid",
	}
	
	$service_name = $::lsbdistcodename ? {
		'precise' => "squid3",
		default => "squid",
	}
	
	$package_name = $::lsbdistcodename ? {
		'precise' => "squid3",
		default => "squid",
	}
	
	$hostname = $::squid_hostname ? {
        '' => "${::hostname}.${::domain}",
        default => "${::squid_hostname}",
    }
    
    $emulate_httpd_log = $squid_emulate_httpd_log ? {
        '' => "on",
        default => "${squid_emulate_httpd_log}",
    }
 
 	$cache_size = $squid_cache_size ? {
        '' => "256",
        default => "${squid_cache_size}",
    }
    
    $port = $squid_port ? {
        '' => "3128",
        default => "${squid_port}",
    }

    $auth_enabled_type = $squid_auth_enabled_type ? {
        '' => "none",
        default => "${squid_auth_enabled_type}",
    }
    
    
	$ldap_auth_binddn = $squid_ldap_auth_binddn ? {
        '' => "CN=Admin,OU=Test,DC=domain,DC=com",
        default => "${squid_ldap_auth_binddn}",
    }    

	$ldap_auth_bindpwd = $squid_ldap_auth_bindpwd ? {
        '' => "Password1",
        default => "${squid_ldap_auth_bindpwd}",
    }
    	
	$ldap_auth_ldaphost = $squid_ldap_auth_ldaphost ? {
        '' => "localhost",
        default => "${squid_ldap_auth_ldaphost}",
    }

	$ldap_auth_ldapport = $squid_ldap_auth_ldapport ? {
        '' => "389",
        default => "${squid_ldap_auth_ldapport}",
    }
    
    $ldap_auth_ldapbasedn = $squid_ldap_auth_ldapbasedn ? {
        '' => "OU=Test,DC=domain,DC=com",
        default => "${squid_ldap_auth_ldapbasedn}",
    }	      	

	$ldap_auth_ldaprealm = $squid_ldap_auth_ldaprealm ? {
        '' => "DC REALM",
        default => "${squid_ldap_auth_ldaprealm}",
    }
    
    # TO define default LDAP groups
    $default_ldap_groups_hash = {
			1 => { 'groupname' => 'Group1', 'ldapgroupname' => 'Users' },
    		2 => { 'groupname' => 'Group2', 'ldapgroupname' => 'Administrators' },    	
    }
    $ldap_auth_groups = $squid_ldap_auth_groups ? {
        '' => $default_ldap_groups_hash,   
        default => $squid_ldap_auth_groups,
    }       
	      
}