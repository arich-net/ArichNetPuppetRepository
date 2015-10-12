# Class: ntp
#
#	Working for ubuntu, check redhat and solaris and ensure correct service restart also.
#
# Operating systems:
#	:Working
#		Ubuntu 10.04
#		RHEL5
# 	:Testing
#
# Parameters:
#	$ntpservers = Array of servers to write to template.
#	$servermode = true/undef (boolean) = configures NTP to act as a server and set restrictions.
#	$subnets = array of subnets required when setting $servermode=true format=(1.1.1.1 mask 255.0.0.0)
#
# Actions:
#
# Requires:
#
# Sample Usage:
#	include ntp - default servers, default client mode
#	class { 'ntp': 
#				ntpservers => ['server1', 'server2' ],
#				servermode => true,
#				subnets => ['subnet1', 'subnet2']
#		  }   	
#
class ntp(
			$ntpservers = ["0.pool.ntp.org", "1.pool.ntp.org", "2.pool.ntp.org", "2.pool.ntp.org"],
			$servermode = undef, 
		  	$subnets = ['192.168.0.0 mask 255.255.0.0',
		  				'10.0.0.0 mask 255.0.0.0'
		  				]
		  ) {
  
		if $servermode { include ntp::config::firewall::server }
		include ntp::config::firewall::client
    
	package {
    	"ntp":
	  		name => $::operatingsystem ? {
	  			ubuntu => "ntp",
	  			debian => "ntp",
	  			redhat => "ntp",
	  			centos => "ntp",
				default => "ntp",
			},
      		ensure => "installed",
  	}

	file {
    	"/etc/ntp.conf":
      		mode => 0644, owner => root, group => root,
			content => template("ntp/ntp.conf.erb"),
			require => [ Package["ntp"] ],
      		notify => [ Service["ntp"] ],
  	}
  
	service {
    	"ntp":
      		name => $::operatingsystem ? {
	  			ubuntu => "ntp",
	  			debian => "ntp",
	  			redhat => "ntpd",
	  			centos => "ntpd",
				default => "ntp",
			},
      		enable => true,
      		ensure => running,
      		hasrestart => true,
      		hasstatus => true,
      		require => File["/etc/ntp.conf"],
  	}
  	
}