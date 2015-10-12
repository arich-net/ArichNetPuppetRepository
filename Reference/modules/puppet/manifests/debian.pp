# Class: puppet::debian
#
# This module manages puppet defaults for debain
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
class puppet::debian {

	apt::preferences { 'puppet':
		ensure => 'present',
		package => 'puppet',
		pin => 'version',
		pin_value => '2.7.19-1puppetlabs2',
		priority => '950',
	}

	apt::preferences { 'puppet-common':
		ensure => 'present',
		package => 'puppet-common',
		pin => 'version',
		pin_value => '2.7.19-1puppetlabs2',
		priority => '950',
	}
		
	file {
		"default-puppet":
        path => "/etc/default/puppet",
        require => Package[puppet],
        ensure => present,
        content => template("puppet/puppet-default.erb"),
        notify => Service["puppet"],
    }
    
}