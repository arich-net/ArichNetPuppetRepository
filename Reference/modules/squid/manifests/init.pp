# Class: squid
#
# Managing Squid Package, service and configuration
#
# Operating systems:
#	:Working
#
# 	:Testing
#
# Parameters:
#  $squid_hostname = Fully qualified domain name of the server
#  $squid_emulate_httpd_log = Emulate 'httpd' log formats
#  $squid_cache_size = Proxy cache size
#  $squid_port = Squid Running Port
#  $squid_directory = Squid Directory
#  $squid_auth_enabled_type = String that by default have "none" it can be "ldap" or "basic"  
#  $squid_ldap_auth_binddn = Bind DN to connect to the LDAP server,
#  $squid_ldap_auth_bindpwd = Bind password to connect to the LDAP server
#  $squid_ldap_auth_ldaphost = LDAP Server host
#  $squid_ldap_auth_ldapport = LDAP Server port
#  $squid_ldap_auth_ldapbasedn = LDAP Base DN to work within the directory structure
#  $squid_ldap_auth_ldaprealm = LDAP Realm
#  $squid_ldap_auth_groups = LDAP Groups enabled with Authorization
#
# Actions:
#
# Requires:
#
# Sample Usage:
#	include squid
#
class squid( $squid_hostname = $::squid::params::hostname, 
	         $squid_emulate_httpd_log = $::squid::params::emulate_httpd_log,			 
        	 $squid_cache_size = $::squid::params::cache_size,
        	 $squid_port = $::squid::params::port,
        	 $squid_auth_enabled_type = $::squid::params::auth_enabled_type,
        	 $squid_ldap_auth_binddn = $::squid::params::ldap_auth_binddn,
        	 $squid_ldap_auth_bindpwd = $::squid::params::ldap_auth_bindpwd,
        	 $squid_ldap_auth_ldaphost = $::squid::params::ldap_auth_ldaphost,
        	 $squid_ldap_auth_ldapport = $::squid::params::ldap_auth_ldapport,
			     $squid_ldap_auth_ldapbasedn = $::squid::params::ldap_auth_ldapbasedn,
			     $squid_ldap_auth_ldaprealm = $::squid::params::ldap_auth_ldaprealm,
			     $squid_ldap_auth_groups = $::squid::params::ldap_auth_groups ) {

	# Load params.pp
	require squid::params

	include squid::config::firewall
    
    package { "${squid::params::package_name}": 
    	ensure => installed 
    }

  	file { "${squid::params::config_path}/squid.conf":
		ensure  => file,
		owner   => root,
		group   => root,
		mode    => 644,
		content => template("squid/squid.conf.erb"),            
		require => Package["${squid::params::package_name}"],
	}
    
    service { "${squid::params::service_name}":
        require     => Package["${squid::params::package_name}"],
        subscribe   => File["${squid::params::config_path}/squid.conf"],
    }
    
    file {"${squid::params::config_path}/conf.d":
        ensure => directory,
        purge => true,
        require => Package["${squid::params::package_name}"],
	}
	
	file {"${squid::params::config_path}/conf.d/ldap.conf":
        ensure => file,
        owner   => root,
		group   => root,
		mode    => 644,
		content => template("squid/ldap.conf.erb"),
        notify => Service["${squid::params::service_name}"],
	}
	
#	file {"${squid::params::config_path}/conf.d/auth_param.conf":
#        ensure => file,
#        owner   => root,
#    group   => root,
#    mode    => 644,
#    content => template("squid/auth_param.conf.erb"),
#  }
	
}