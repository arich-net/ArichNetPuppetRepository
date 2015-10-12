# Class: snmp
#
# This module manages snmp package and service.
#
# Operating systems:
#	:Working
#		Ubuntu 10.04
#		RHEL5
# 	:Testing
#
# Parameters:
#	$snmpro = snmp RO string to pass to template
#	$snmdisks = snmp disks to monitor
#
# Actions:
#
# Requires:
#
# Sample Usage:
#	    class { 'snmp':
#    			snmpro => "testing-string",
#    			snmpdisks => ["/some", "/file"],
#    	}
#
# [Remember: No empty lines between comments and class definition]
class snmp(
			$snmpro = $::snmp::params::snmp_snmpro,
			$snmpdisks = $::snmp::params::snmp_snmpdisks,
			$snmpfile = $::snmp::params::snmp_snmpfile,
		
) inherits snmp::params {
	
	include snmp::config::firewall
	
    package { "snmpd":
    	name => $operatingsystem ? {
	  		ubuntu => "snmpd",
	  		debian => "snmpd",
	  		redhat => "net-snmp",
	  		centos => "net-snmp",
			default => "snmpd",
		},
    	ensure => present,
    }

    file { "/etc/snmp/snmpd.conf":
        content => inline_template(
          file(
            "/etc/puppet/environments/$::environment/templates/snmp/$snmpfile",            
            "/etc/puppet/modules/snmp/templates/snmpd.conf.erb" # Using inline_template this needs to be full path
          )          
        ),        
        notify => Service["snmpd"],
        require => Package["snmpd"],
    }

    service { "snmpd":
        enable => true,
        ensure => running,
		pattern => "snmpd",
		hasrestart => true,
		# Note: This isn't an issue but it causes a flag of a "change" to be set to dashboard
		# hasstatus => false to force puppet to use 'ps -ef' to check for snmpd process.
		# this is because othewise ubuntu latest init.d script will exit with >0 error code 
		# because snmptrapd is not started.
		# we can use case statements in the future based on OS perhaps.
		hasstatus => false,
		require => Package["snmpd"],
		subscribe => File["/etc/snmp/snmpd.conf"],
    }
	
}