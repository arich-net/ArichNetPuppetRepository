# Class: sysapi
#
# SysAPI, used internal for multiple tasks.
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
class c336792_sysapi {

	file { "/usr/local/sysapi":
		ensure  => directory,
		owner => root,
    	group => root,
		recurse => true,
		purge => true,
		force => true, # Forces a removal if ensure => absent
		backup => false,
		source => "puppet:///modules/c336792_sysapi/sysapi/"
	}
   
   
	file { "/usr/local/sysapi/logs":
		ensure => directory,
		owner => 'www-data',
    	group => 'www-data',
	   	mode => 0755,
	   	recurse => true,
		require => File['/usr/local/sysapi'],
	}
	
	file { "/usr/local/sysapi/var":
		ensure => directory,
		owner => 'www-data',
    	group => 'www-data',
	   	mode => 0755,
	   	#recurse => true,
		require => File['/usr/local/sysapi'],
	}

	file { "/usr/local/sysapi/csv":
		ensure => directory,
		owner => 'www-data',
    	group => 'www-data',
	   	mode => 0755,
	   	#recurse => true,
		require => File['/usr/local/sysapi'],
	}

	file { "/usr/local/sysapi/rack/config.ru":
		owner => 'www-data',
    	group => 'www-data',
	   	mode => 0644,
	   	source => "puppet:///modules/c336792_sysapi/sysapi/rack/config.ru",
		require => File['/usr/local/sysapi'],
	}

	# Add Vhost config
	apache::vhost { 'sysapi':
    	template => 'sysapi-vhost.conf.erb',
    }		
				     
}
