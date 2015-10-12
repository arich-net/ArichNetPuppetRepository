# Class: clamav
#
# Supports clamav/daemon package and configuration
#	When specified to not run as a daemon the class will add a cron entry detailed in class:clamav::cron
#
# Operating systems:
#	:Working
#		Ubuntu 10.04
#
# 	:Testing
#
# Parameters:
#	$clamav_runasdaemon = true/false boolean
#	$clamav_cron_command = Command to run as cron, default is "clamscan -r / > /dev/null 2>&1"
#	$clamav_cron_hour = what hour to run scan, default is "0"
#	$clamav_cron_minute = what minute to run scan, default is "0"  
#
# Actions:
#
# Requires:
#
# Sample Usage:
#	class { 'clamav': 
#		clamav_runasdaemon => false
#		clamav_cron_hour = "2",
#		clamav_cron_minute = "45"
#	}
#
class clamav(   $clamav_runasdaemon = $clamav::params::runasdaemon,
				$clamav_cron_enable = $clamav::params::cron_enable,
				$clamav_cron_command = $clamav::params::cron_command,
				$clamav_cron_hour = $clamav::params::cron_hour,
				$clamav_cron_minute = $clamav::params::cron_minute,
				$clamav_proxy_server = $clamav::params::proxy_server,
				$clamav_proxy_port = $clamav::params::proxy_port,
				$clamav_proxy_username = $clamav::params::proxy_username,
				$clamav_proxy_password = $clamav::params::proxy_password
				
) inherits clamav::params {
	
	# Install packages based on OS, redhat includes freshclam and daemon binarys in "clamav"
	# Ubuntu has a dependency of freshclam on clamav and we install clamav-daemon aswell.
	package { $clamav::params::clamav_package :
		ensure => installed,
	}
	
	service { "clamav-daemon":
		enable => $clamav_runasdaemon,
		ensure => $clamav_runasdaemon ? {
			true => "running",
			false => "stopped",
			default => "stopped"
		},
		hasrestart => true,
		hasstatus => true,
		subscribe => File["/etc/clamav/clamd.conf"],
		require => Package[$clamav::params::clamav_package]
    }
	
	service { "clamav-freshclam":
		ensure => true,
		enable => true,
		hasrestart => true,
		hasstatus => true,
		subscribe => File["/etc/clamav/freshclam.conf"],
		require => Package[$clamav::params::clamav_package]
	}

	file { "/etc/clamav/freshclam.conf":
		path => "/etc/clamav/freshclam.conf",
		content => template("clamav/freshclam.conf.erb"),
		ensure => present,
		mode   => 644,
		owner  => root,
		group  => root,
		before => Service["clamav-freshclam"],
		require => Package[$clamav::params::clamav_package]
    }
    
    
	file { "/etc/clamav/clamd.conf":
       path => "/etc/clamav/clamd.conf",
       content => template("clamav/clamd.conf.erb"),
       ensure => present,
       mode   => 644,
       owner  => root,
       group  => root,
       before => Service["clamav-daemon"],
       require => Package[$clamav::params::clamav_package]
    }
    
    # Include cron class to add/remove cron entry based on $clamav_runasdaemon
	class { 'clamav::cron':
		ensure  => $clamav_cron_enable ? {
			true => "present",
			false => "absent",
			default => "absent"
		},
		command => $clamav_cron_command,
		hour => $clamav_cron_hour,
		minute => $clamav_cron_minute
	}

}