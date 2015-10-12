# Class: puppet::puppeteer
#
# This module manages a puppeteer setup, mainly a different config, but we use a seperate class
#	to help organize things.
#
# Parameters:
#	$puppet_storeconfigs = true/false, setup/config DB for puppet stored configuration (ext resources)
#	$puppet_storeconfigs_db = DB name, defaults to "puppet"
#	$puppet_storeconfigs_dbuser = DB user name, defaults to "puppet"
#	$puppet_storeconfigs_dbpasswd = DB user passwd, defaults to "puppet"
#
# Actions:
#
# Requires:
#
# Sample Usage:
# class { 'puppet::puppeteer': }
#
# [Remember: No empty lines between comments and class definition]
class puppet::puppeteer($puppet_storeconfigs = $::puppet::params::storeconfigs,
						$puppet_storeconfigs_db = $::puppet::params::storeconfigs_db,
						$puppet_storeconfigs_dbuser = $::puppet::params::storeconfigs_dbuser,
						$puppet_storeconfigs_dbpasswd = $::puppet::params::storeconfigs_dbpasswd,
						$puppet_passenger = $::puppet::params::passenger,
						$puppet_is_ca_server = $::puppet::params::is_ca_server,
) {
	
	include puppet::repo::puppetlabs
	include puppet::params
    			
	package { "puppetmaster":
		ensure => present,
		name => $::operatingsystem ? {
			Ubuntu => "puppetmaster",
			Debian => "puppetmaster",
			RedHat => "puppet-server",
			default => "puppetmaster",
		},
		require => [Class["puppet::repo::puppetlabs"], Exec['apt-get_update']],
	}
	
	file {"${puppet::params::configdir}":
			ensure => directory,
			require => Package["puppetmaster"],
			owner => 'puppetadmin',
			group => 'puppetadmin',
	}

	package { "rdoc":
		ensure => present,
		name => $::operatingsystem ? {
			RedHat => "ruby-rdoc",
			default => "rdoc",
			},
	}
	
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
		
	file {"/etc/puppet-extpackages/":
		require => Package["puppet"],
		ensure => directory, # directory/absent
		owner => 'puppetadmin',
		group => 'puppetadmin',		
	}
	
	# Setup stored config if set.
	if $puppet_storeconfigs {
    	class { 'puppet::storedconfig':
    		storedconfig_db => $puppet_storeconfigs_db,
    		storedconfig_dbuser => $puppet_storeconfigs_dbuser,
    		storedconfig_dbpasswd => $puppet_storeconfigs_dbpasswd,
      	}
	}

	# include external classes if required.
	if $puppet_passenger { include puppet::config::passenger }
}
