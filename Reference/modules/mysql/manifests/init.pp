# Class: mysql
#
# Used for MySQL to install, setup and manage DB, users, permissions etc.
#
# Parameters:
#
# Actions:
#	1) Create a seperate define for db, user, grants.
#
# Requires:
#
# Sample Usage:
#
# #Providers
#
#	database { 'mydb':
#	}
#	database_user { 'user@localhost':
#		password_hash => mysql_password('foobar')
#	}
#	database_grant { 'user@localhost/database': # can be per db or global i.e 'user@localhost'
#		privileges => ['all'] ,
#	}
#
# [Remember: No empty lines between comments and class definition]
class mysql() {
	include mysql::params

	package {"mysql-client":
    	name => $mysql::params::client_package_name,
    	ensure => installed,
	}
	
}