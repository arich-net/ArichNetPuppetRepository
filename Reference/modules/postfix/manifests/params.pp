# Class: postfix::params
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
class postfix::params  {
  # Static parameters
  
  $mailname = "/etc/mailname"
	
	$myhostname = $postfix_myhostname ? {
        '' => "$::FQDN",
        default => "${postfix_myhostname}",
    }
    
    $mydomain = $postfix_mydomain ? {
        '' => "",
        default => "${postfix_mydomain}",
    }
		  
	# Needs to be an array due to a an external lookup var using join in tpl main.cf.erb
    $mynetworks = $postfix_mynetworks ? {
        '' => ['127.0.0.1'],
        default => $postfix_mynetworks,
    }
    
    $messagesizelimit = $postfix_messagesizelimit ? {
        '' => "10240000",
        default => "${postfix_messagesizelimit}",
    }
    
    $ipblacklist = $postfix_ipblacklist ? {
    	'' => [],
    	default => $postfix_ipblacklist,
    }
    
    $smtpd_client_connection_count_limit = $postfix_smtpd_client_connection_count_limit ? {
    	'' => "50",
    	default => $postfix_smtpd_client_connection_count_limit,
    }
    
    $smtpd_client_connection_rate_limit = $postfix_smtpd_client_connection_rate_limit ? {
    	'' => "0",
    	default => $postfix_smtpd_client_connection_rate_limit,
    }
    
    $anvil_rate_time_unit = $postfix_anvil_rate_time_unit ? {
    	'' => "60s",
    	default => $postfix_anvil_rate_time_unit,
    }
    
    $append_dot_mydomain = $postfix_append_dot_mydomain ? {
    	'' => "yes",
    	default => $postfix_append_dot_mydomain,
    }
    
    $relayhost = $postfix_relayhost ? {
    	'' => "",
    	default => $postfix_relayhost,
    }
    
    $inet_interfaces = $postfix_inet_interfaces ? {
    	'' => "all",
    	default => $postfix_inet_interfaces,
    }
        
	$packagename = $::operatingsystem ? {
        solaris => "CSWpostfix",
        default => "postfix",
    }

    $servicename = $::operatingsystem ? {
        default => "postfix",
    }

	$configfile = $::operatingsystem ? {
        default => "/etc/postfix/main.cf",
    }
    
	$configdir = $::operatingsystem ? {
		freebsd => "/usr/local/etc/postfix/",
        default => "/etc/postfix",
    }
    
    $clientfilter = $::operatingsystem ? {
    	default => "/etc/postfix/access_client",
    }
    
    $alias_file = $::operatingsystem ? {
    	default => "/etc/aliases",
    }
    
    $recipient_access = $::operatingsystem ? {
    	default => "/etc/postfix/recipient_access",
    }
}