# Define: splunk::authldap
#
# This module manages splunk authentication
#
# Operating systems:
#	:Working
#
# 	:Testing
#		Ubuntu 10.04
#		RHEL5
#
# Parameters:
#	host = host currently only specify one host, I need to check if splunk accepts more then 1
#	port = this defaults to 636 as the file has ssl_enable = 1
#	search_base = search base 
#	bind_dn = bind dn 
#	bind_passwd = MD5 passwd
#
# Actions:
#	1) Restrict this to only be defined on indexers..?
#	2) Convert to a define using splunks cli.
#
# Requires:
#
# Sample Usage:
# ONLY TO BE USED ON INDEXERS
#
# Splunk defaults to local internal splunk users, this will override that.
#	splunk::authldap { 'ntteng':
#		host => 'evw3300026.ntteng.ntt.eu',
#		port => '636' 
#		search_base => 'ou=NTT EO,dc=ntteng,dc=ntt,dc=eu', 
#		bind_dn => 'cn=NTTEO LDAP Service,cn=Users,dc=ntteng,dc=ntt,dc=eu', 
#		bind_passwd => '$1$brjHS+nb3AyjAlE=',
#	}
#
# [Remember: No empty lines between comments and class definition]
define splunk::authldap($host, $port='636', $search_base, $bind_dn, $bind_passwd) {
	
	splunk::define::managedir { "/opt/splunk/etc/system/local": }
	
		file { "/opt/splunk/etc/system/local/authentication.conf":
    		owner   => root,
    		group   => root,
    		mode    => 0644,
    		content => template("splunk/etc/system/local/authentication.conf.erb"),
    		require => Package["splunk"],
  		}
}