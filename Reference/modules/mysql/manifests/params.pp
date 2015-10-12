# Class: mysql::params
#
# Used for MySQL to install, setup and manage DB, users, permissions etc.
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
class mysql::params() {

	$socket = '/var/run/mysqld/mysqld.sock'
	case $::operatingsystem {
    	'centos', 'redhat', 'fedora': {
      		$service_name = 'mysqld'
      		$client_package_name = 'mysql'
      		$server_package_name = 'mysql-server'
      		$ruby_mysql_package_name = 'ruby-mysql'
    	}
    	'ubuntu', 'debian': {
      		$service_name = 'mysql'
      		$client_package_name = 'mysql-client'
      		$server_package_name = 'mysql-server'
      		$ruby_mysql_package_name = 'libmysql-ruby1.8'
    	}
    	default: {
    		fail("class mysql::params - operatingsystem $::operatingsystem is not supported")
    	}
  	}
}