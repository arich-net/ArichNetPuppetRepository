# Class: apache::passenger
#
# This class installs Apache passenger GEM
#
# Parameters:
#
# Actions:
#	1) upgrade passenger gem in apache::params, will require gcc/build-essential and some libcurl libs.
#
# Requires:
#
# Sample Usage:
#
class apache::passenger {
	
	# compile-passenger requires GNU compiler located in build-essential package
	
	include apache::params

	require ruby::dev
	require apache::dev
	require apache::ssl

	package {'passenger':
    	name => 'passenger',
    	ensure => $apache::params::passenger_ver,
    	provider => 'gem',
    	require => [ Package['rubygems'], Package['httpd'] ],
	}

	exec {'compile-passenger':
		path => [ $apache::params::gem_binary_path, '/usr/bin', '/bin'],
		command => 'passenger-install-apache2-module -a',
		logoutput => true,
		creates => $apache::params::mod_passenger_location,
		require => Package['passenger'],
	}
	
	file {"${apache::params::confdir}/10_passenger.conf":
    	owner => 'root',
    	group => 'root',
    	mode => '644',
    	content => template('apache/10_passenger.conf.erb'),
    	require => Package['httpd'],
    	notify => Service['httpd'],
	}
  
}
