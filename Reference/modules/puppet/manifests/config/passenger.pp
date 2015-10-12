# Class: puppet::config::passenger
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
class puppet::config::passenger {
  	
	apache::vhost { 'puppetmaster':
    	template => 'puppetmaster-vhost.conf.erb',
    }
  	
  	file {"${puppet::params::passenger_app_root}":
  		ensure => 'directory',
    	owner => 'puppet',
    	group => 'root',
    	mode => '644',
    }
    
    file {"${puppet::params::passenger_app_root}/public":
  		ensure => 'directory',
    	owner => 'root',
    	group => 'root',
    	mode => '644',
    	require => File["${puppet::params::passenger_app_root}"],
    }
    
	file {"${puppet::params::passenger_app_root}/config.ru":
  		ensure => 'present',
    	owner => 'puppet',
    	group => 'root',
    	mode => '644',
		content => template("puppet/config.ru.erb"),
		require => File["${puppet::params::passenger_app_root}"],
    }
    file {"${puppet::params::passenger_app_root}/public/puppet":
  		ensure => 'link',
    	owner => 'root',
    	target => '/usr/lib/ruby/1.8/puppet',
    	require => File["${puppet::params::passenger_app_root}/public"],
    }
  	
}