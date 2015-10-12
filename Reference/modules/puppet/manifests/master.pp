# Class: puppet::master
#
# This module manages puppet master
#
# Parameters:
#
# Actions:
#
# Requires:
#
# Sample Usage:
# class { 'puppet::master': }
#
# [Remember: No empty lines between comments and class definition]
class puppet::master(
					$puppet_passenger = $::puppet::params::passenger,
					$puppet_is_ca_server = $::puppet::params::is_ca_server,
					$puppet_firewall = $puppet::params::firewall
) inherits puppet::params {
	
	include puppet::repo::puppetlabs
	
    if $puppet_firewall { include puppet::config::firewall::master }
    
	package { "puppetmaster":
		ensure => present,
		name => $operatingsystem ? {
			Ubuntu => "puppetmaster",
			Debian => "puppetmaster",
			RedHat => "puppet-server",
			default => "puppetmaster",
		},
		require => [Class["puppet::repo::puppetlabs"], Exec['apt-get_update']],
	}
	
	#
	# pin the masters, we already know there on ubuntu
	#
	apt::preferences { 'puppetmaster':
		ensure => 'present',
		package => 'puppetmaster',
		pin => 'version',
		pin_value => '2.7.19-1puppetlabs2',
		priority => '950',
	}

	apt::preferences { 'puppetmaster-common':
		ensure => 'present',
		package => 'puppetmaster-common',
		pin => 'version',
		pin_value => '2.7.19-1puppetlabs2',
		priority => '950',
	}
	

	package { "rdoc":
		ensure => present,
		name => $operatingsystem ? {
			RedHat => "ruby-rdoc",
			default => "rdoc",
			},
	}
	
	# pre reqs for stored config support
	#package { "rails":
    #	ensure => installed,
    #	provider => gem,
    #	require => Package["puppetmaster"]
	#}
	#package { "activerecord":
    #	ensure => installed,
    #	provider => gem,
    #	require => Package["puppetmaster"]
	#}
	
	service { "puppetmaster":
		ensure => $puppet_passenger ? {
      				true => "stopped",
      				false => "running"
    	},
		enable => $puppet_passenger ? {
      				true => "false",
      				false => "true",
    	},
		hasrestart => true,
		hasstatus => true,
	}
	
	# Required permissions for our rsync user from puppeteer > masters
	file {"${puppet::params::configdir}":
			ensure => directory,
			require => Package["puppetmaster"],
			owner => 'puppetadmin',
			group => 'puppetadmin',
	}
	
	file {"/etc/puppet-extpackages/":
		require => Package["puppet"],
		ensure => directory, # directory/absent
		owner => 'puppetadmin',
		group => 'puppetadmin',		
	}
	
	# include external classes if required.
	if $puppet_passenger { include puppet::config::passenger }
	

}
