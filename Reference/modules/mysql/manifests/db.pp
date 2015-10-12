# define: mysql::db
#
# Used to create and manage DB creation and privileges.
#
# Parameters:
#
#	$title - database name
#	$user - user to create
#	$password - user's password
#	$charset - charset for db
#	$host - host for assigning privileges to user
#	$grant - array of privileges to grant to user
#	$sql - sql to inject in db (always runs)
#
# Actions:
#
# Requires:
#
# Sample Usage:
#
# 	mysql::db { 'mydb':
# 		user => 'my_user',
# 		password => 'password',
# 		host => $::hostname,
# 		grant => ['all'],
#		grant => ['select_priv', 'insert_priv'],
# 	}
# privileges => [ 'alter_priv', 'insert_priv', 'select_priv', 'update_priv' ],
#
# [Remember: No empty lines between comments and class definition]
define mysql::db (
  					$user,
  					$password,
  					$charset = 'utf8',
  					$host = 'localhost',
  					$grant='all',
  					$sql='') 
{

  database { $name:
    ensure => present,
    charset => $charset,
    provider => 'mysql',
    require => Class['mysql::server']
  }
  database_user{"${user}@${host}":
    ensure => present,
    password_hash => mysql_password($password),
    provider => 'mysql',
    require => Database[$name],
  }
  database_grant{"${user}@${host}/${name}":
    privileges => $grant,
    provider => 'mysql',
    require => Database_user["${user}@${host}"],
  }
  if($sql) {
    exec{"${name}-import-import":
      command => "/usr/bin/mysql -u ${user} -p${password} -h ${host} ${name} < ${sql}",
      logoutput => true,
      require => Database_grant["${user}@${host}/${name}"],
    }
  }
} 