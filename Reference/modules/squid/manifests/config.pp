# Class squid::config
#
# This definition manages squid configuration
#
# Parameters:
#	#squid::config::acl
#		$aclarray = an array hash of values using keys as integers if order is required (see usage)
#			name = name for your acl
#			type = src,dst,port (based on squid config)
#			setting = value to apply to above type
#
# Actions:
#
# Requires:
#
# Sample Usage:
#	#squid::config::acl
#		# within a class define the array in an ordered integer list
#		$myaclarray =  {
#    		1 => { 'name' => 'aclname', 'type' => 'port', 'setting' => '123', 'desc' => 'Description of the rule' },
#    		2 => { 'name' => 'aclname', 'type' => 'port', 'setting' => '456', 'desc' => 'Description of the rule' },
#		}
#		# Then call the define passing the array
#		squid::config::acl { 'my_squid_acls':
#			aclarray => $myaclarray,
#		}
#
#	#squid::config::http_access
#		# within a class define the array in an ordered integer list
#		$myhttparray =  {
#    		1 => { 'policy' => 'allow', 'acl1' => 'acl name 1', 'acl2' => '' },
#    		2 => { 'policy' => 'deny', 'acl1' => 'acl name 2', 'acl2' => 'acl name 2' },
#		}
#		# Then call the define passing the array
#		squid::config::http_access { 'my_squid_http_access':
#			httparray => $myhttparray,
#		}
#	
# [Remember: No empty lines between comments and class definition]
class squid::config() { 

	define acl($aclarray) {
		file {"${squid::params::config_path}/conf.d/acls.conf":
			ensure => present,
			content => template("squid/acls.conf.erb"),
			notify => Service["${squid::params::service_name}"],
		}
	}
	
	define http_access($httparray) {
		file {"${squid::params::config_path}/conf.d/http_access.conf":
			ensure => present,
			content => template("squid/http_access.conf.erb"),
			notify => Service["${squid::params::service_name}"],
		}
	}
	
	define auth_param($autharray) {
    file {"${squid::params::config_path}/conf.d/auth_param.conf":
      ensure => present,
      content => template("squid/auth_param.conf.erb"),
      notify => Service["${squid::params::service_name}"],
    }
  } 	
}