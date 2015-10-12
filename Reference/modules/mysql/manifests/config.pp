# Class: mysql::config
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
#	Called from mysql::server
#
# [Remember: No empty lines between comments and class definition]
class mysql::config(
  					$root_password = 'UNSET',
  					$old_root_password = '',
  					$bind_address = '127.0.0.1',
  					$port = 3306,
  					# shall we store root password in /etc/my.cnf ? true/false
  					$etc_root_password = false) 
{

	# manage root password if it is set
  	if !($root_password == 'UNSET') {
    	case $old_root_password {
      		'': {$old_pw=''}
      		default: {$old_pw="-p${old_root_password}"}
    	}
    
		exec{ 'set_mysql_rootpw':
			command => "mysqladmin -u root ${old_pw} password ${root_password}",
      		#logoutput => on_failure,
      		logoutput => true,
      		unless => "mysqladmin -u root -p${root_password} status > /dev/null",
      		path => '/usr/local/sbin:/usr/bin',
      		require => [Package['mysql-server'], Service['mysqld']],
      		before => File['/root/.my.cnf'],
      		notify => Exec['mysqld-restart'],
    	}
    
		#	 Root password location
		file{'/root/.my.cnf':
      		content => template('mysql/my.cnf.pass.erb'),
    	}
    	
    	#if $etc_root_password { 
			file{'/etc/my.cnf':
				ensure => $etc_root_password ? {
      					true  => 'present',
      					false => 'absent',
    			},
          		content => template('mysql/my.cnf.pass.erb'),
          		require => Exec['set_mysql_rootpw'],
       		}
    	#}
    		
    	
    } # End if !($root_password == 'UNSET')
    
	File {
    	owner => 'root',
    	group => 'root',
    	mode => '0400',
    	notify => Exec['mysqld-restart'],
    	require => Package['mysql-server']
  	}
  	file { '/etc/mysql':
    	ensure => directory,
    	mode => '755',
  	}
	file { '/etc/mysql/my.cnf':
    	content => template('mysql/my.cnf.erb'),
  	}
}