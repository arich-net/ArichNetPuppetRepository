# Class: foreman::repo::foreman
#
# This class defines the apt sources/keys & preferences for the foreman repo
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
class foreman::repo::foreman(){

	case $::operatingsystem {
    	redhat,centos,fedora,Scientific: {
      		yumrepo {
        		"foreman":
          			descr => "Foreman stable repository",
          			baseurl => "http://yum.theforeman.org/stable",
          			gpgcheck => "0",
          			enabled => "1";
        		"foreman-testing":
          			descr => "Foreman testing repository",
          			baseurl => "http://yum.theforeman.org/test",
          			enabled => $foreman::params::use_testing ? {
            					true => "1",
            					default => "0",
          			},
          			gpgcheck => "0",
      		}
    	}
    	Debian,Ubuntu: {
			apt::source { 'foreman':
				ensure       => present,
	          	type     => 'deb',
            	uri          => "http://deb.theforeman.org/",
            	dist => "${::lsbdistcodename}",
	          	components   => [ 'stable' ],
        	}
			apt::key { 'E775FF07':
				ensure => 'present',
				source => 'http://deb.theforeman.org/foreman.asc'		
			}      
    	}
    	default: { fail("${::hostname}: This module does not support operatingsystem $::operatingsystem") }
  	}

}
