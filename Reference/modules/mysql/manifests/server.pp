# Class: mysql::server
#
#
# Parameters:
#	$root_password = mysql root user passwd, clear text and will be hashed, else is UNSET
#	$old_root_password = set all passwd if changing passwd
#	$bind_address = bind address
#	$port = mysql port
#	$etc_root_password = Store root passwd in /etc/my.cnf = true/false 
#
# Actions:
#
# Requires:
#
# Sample Usage:
#	class { 'mysql::server': 
#		config_hash => { 'root_password' => 'foobar' }
#	}
#
# [Remember: No empty lines between comments and class definition]
class mysql::server($config_hash  = {}) {
	include mysql::params
	
	# automatically create a class to deal with configuration
  	$hash = {
    	"mysql::config" => $config_hash
  	}
  	create_resources("class", $hash)
	
	package{'mysql-server':
    	name => $mysql::params::server_package_name,
    	ensure => present,
    	notify => Service['mysqld'],
  	}
  	
	service { 'mysqld':
    	name => $mysql::params::service_name,
    	ensure => running,
    	enable => true,
  	}
  	
  	exec{ 'mysqld-restart':
    	command => "service ${mysql::params::service_name} restart",
    	refreshonly => true,
    	path => '/sbin/:/usr/sbin/',
  	}
  
}