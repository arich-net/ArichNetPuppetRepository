# Class: rhn::params
#
# Redhat Network
#
# Operating systems:
#	:Working
#
# 	:Testing
#
# Parameters:
#	$server
#	
# Actions:
#
# Requires:
#
# Sample Usage:
#	include rhn
#
class rhn::params() {

	$server = $rhn_server ? {
		'' => undef,
		default => $rhn_server,
    }

	$activationkey = $rhn_activationkey ? {
		'' => undef,
		default => $rhn_activationkey,
    }

	$use_proxy = $rhn_use_proxy ? {
		'' => undef,
		default => $rhn_use_proxy,
    }    
    
	$http_proxy = $rhn_http_proxy ? {
		'' => undef,
		default => $rhn_http_proxy,
    }    
    
	$sslcacert = $rhn_sslcacert ? {
		'' => "/usr/share/rhn/RHN-ORG-TRUSTED-SSL-CERT",
		default => $rhn_sslcacert,
    }        

	$proxyuser = $rhn_proxyuser ? {
		'' => undef,
		default => $rhn_proxyuser,
    }        

	$proxypass = $rhn_proxypass ? {
		'' => undef,
		default => $rhn_proxypass,
    }        

	$systemidpath = $rhn_systemidpath ? {
		'' => "/etc/sysconfig/rhn/systemid",
		default => $rhn_systemidpath,
    }        
        
}