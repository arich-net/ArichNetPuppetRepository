# Class: postfix
#
# Parameters:
#	$postfix_myhostname = mailserver hostname, defaults to FQDN. ***** FQDN NOT WORKING *****
#	$postfix_mynetworks = Needs to be an array of allowed network subnets. 
#	$postfix_messagesizelimit = Size of queued mail for relaying, default 10240000
#	$postfix_ipblacklist = Array of IP address blacklisted
#	$postfix_smtpd_client_connection_count_limit = How many simultaneous connections any client is allowed to make to this service
#	$postfix_smtpd_client_connection_rate_limit = The maximal number of connection attempts any client is allowed to make to this service per time unit
#	$postfix_anvil_rate_time_unit = The time unit over which client connection rates and other rates are calculated
#	$postfix_append_dot_mydomain = With locally submitted mail, append the string ".$mydomain" to addresses that have no ".domain" information
#	$postfix_relayhost = The next-hop destination of non-local mail; overrides non-local domains in recipient addresses.
#	$postfix_inet_interfaces = The network interface addresses that this mail system receives mail on.
#
# Actions:
#	1) Maybe change main.cf for an inline template to enable environment templates to be used. main.cf is
#		fairly generic and is populated with param variables so maybe not required.
#
# Requires:
#
# Sample Usage:
#
# [Remember: No empty lines between comments and class definition]
class postfix(	$postfix_myhostname = $::postfix::params::myhostname,
				$postfix_mydomain = $::postfix::params::mydomain,
				$postfix_mynetworks = $::postfix::params::mynetworks,
				$postfix_messagesizelimit = $::postfix::params::messagesizelimit,
				$postfix_ipblacklist = $::postfix::params::ipblacklist,
				$postfix_smtpd_client_connection_count_limit = $::postfix::params::smtpd_client_connection_count_limit,
				$postfix_smtpd_client_connection_rate_limit = $::postfix::params::smtpd_client_connection_rate_limit,
				$postfix_anvil_rate_time_unit = $::postfix::params::anvil_rate_time_unit,
				$postfix_append_dot_mydomain = $::postfix::params::append_dot_mydomain,
				$postfix_relayhost = $::postfix::params::relayhost,
				$postfix_inet_interfaces = $::postfix::params::inet_interfaces,
) {
	
	# Load params.pp
	require postfix::params

    package { "postfix":
        name => "${postfix::params::packagename}",
        ensure => present,
    }

    service { "postfix":
        name => "${postfix::params::servicename}",
        ensure => running,
        enable => true,
        require => Package["postfix"],        			
        subscribe => [File["main.cf"], File["access_client"], File["alias_file"]],
    }

    file { "main.cf":
        path => "${postfix::params::configfile}",
        ensure => present,
        require => Package["postfix"],
        notify => Service["postfix"],
        content => template("postfix/main.cf.erb"),
    }
    
    file { "access_client":
    	path => "${postfix::params::clientfilter}",
    	ensure => present,
    	require => Package["postfix"],
        notify => Exec["postfix_hash_access_client"],
        content => template("postfix/access_client.erb"),        
    }
    
    file { "alias_file":
    	path => "${postfix::params::alias_file}",
    	notify => Exec["postfix_hash_alias_file"], 	              
    }
    
    file { "recipient_access":
    	path => "${postfix::params::recipient_access}", 
        require => Package["postfix"],
    	content => template("postfix/recipient_access.erb"), 	    	              
    }
    
    file { "mailname":
      path => "${postfix::params::mailname}",
      require => Package["postfix"], 
      content => template("postfix/mailname.erb"),                      
    }
    
    exec { "postfix_hash_access_client":
    	path => "/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin",
    	command => "postmap hash:${postfix::params::clientfilter}",
    }
    
    exec { "postfix_hash_alias_file":
    	path => "/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin",
    	command => "postalias hash:${postfix::params::alias_file}",
    	refreshonly => true,
    	subscribe => File["alias_file"],
    	notify => Service["postfix"],   	
    }

    case $::operatingsystem {
        redhat: {  }
        centos: {  }
        debian: {  }
        default: { }
    }

}