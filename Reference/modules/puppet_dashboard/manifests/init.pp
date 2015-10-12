# Class: puppet_dashboard
#
# This module manages puppet dashboard
#
# Parameters:
#
# Actions:
#	1) Patch required on Ubuntu lucid LTS :: http://projects.puppetlabs.com/issues/8800
##
# Requires:
#	1) Class mysql
#	2) Class mysql::server
#	3) Class mysql::ruby
#
# Sample Usage:
#	class { 'puppet_dashboard': $dashboard_password => '<passwd>' }
#
# [Remember: No empty lines between comments and class definition]
class puppet_dashboard(
	$dashboard_ensure = $::puppet_dashboard::params::dashboard_ensure,
	$dashboard_user = $::puppet_dashboard::params::dashboard_user,
	$dashboard_group = $::puppet_dashboard::params::dashboard_group,
	$dashboard_password = $::puppet_dashboard::params::dashboard_password,
  	$dashboard_db = $::puppet_dashboard::params::dashboard_db,
  	$dashboard_dbuser = $::puppet_dashboard::params::dashboard_dbuser,
  	$dashboard_dbpassword = $::puppet_dashboard::params::dashboard_dbpassword,
  	$dashboard_dbcharset = $::puppet_dashboard::params::dashboard_dbcharset,
  	$dashboard_site = $::puppet_dashboard::params::dashboard_site,
  	$dashboard_port = $::puppet_dashboard::params::dashboard_port, 
  	$dashboard_inventory = $::puppet_dashboard::params::dashboard_inventory,
  	$passenger = $::puppet_dashboard::passenger
) inherits puppet_dashboard::params {
	
	# We want to include these at node level incase we need to pass specific params.
  	require mysql
	require mysql::server
	require mysql::ruby

	if $passenger {
    	Class['mysql']
    		-> Class['mysql::ruby']
    		-> Class['mysql::server']
    		-> Package[$dashboard_package]
    		-> Mysql::DB["${dashboard_db}"]
    		-> File["${puppet_dashboard::params::dashboard_root}/config/database.yml"]
    		-> Exec['db-migrate']
    		-> Class['puppet_dashboard::passenger']

    	class { 'puppet_dashboard::passenger':
      		dashboard_site => $dashboard_site,
      		dashboard_port => $dashboard_port,
    	}

  	} else {
    	Class['mysql']
    		-> Class['mysql::ruby']
    		-> Class['mysql::server']
    		-> Package[$dashboard_package]
    		-> Mysql::DB["${dashboard_db}"]
    		-> File["${puppet_dashboard::params::dashboard_root}/config/database.yml"]
    		-> Exec['db-migrate']
    		-> Service[$dashboard_service]

		case $::operatingsystem {
			'centos','redhat','oel': {
        		file { '/etc/sysconfig/puppet-dashboard':
          			ensure => present,
          			content => template('puppet_dashboard/sysconfig.erb'),
          			owner => '0',
          			group => '0',
          			mode => '0644',
          			require => [ Package[$dashboard_package], User[$dashboard_user] ],
          			before => Service[$dashboard_service],
        		}
      		}
      		'debian','ubuntu': {
        		file { '/etc/default/puppet-dashboard':
          			ensure => present,
          			content => template('puppet_dashboard/default.erb'),
          			owner => '0',
          			group => '0',
          			mode => '0644',
          			require => [ Package[$dashboard_package], User[$dashboard_user] ],
          			before => Service[$dashboard_service],
        		}
      		}
		}

    	service { $dashboard_service:
    		ensure => running,
      		enable => true,
      		hasrestart => true,
      		subscribe => [ File['/etc/puppet-dashboard/database.yml'], File["${puppet_dashboard::params::dashboard_root}/config/settings.yml"] ],
      		require => Exec['db-migrate']
    	}
	
	} # if $passenger else

	package { $dashboard_package:
    	ensure => $dashboard_ensure,
  	}

	File {
    	require => Package[$dashboard_package],
    	mode => '0755',
    	owner => $dashboard_user,
    	group => $dashboard_group,
  	}

  	file { [ "${puppet_dashboard::params::dashboard_root}/public", "${puppet_dashboard::params::dashboard_root}/spool", "${puppet_dashboard::params::dashboard_root}/tmp", "${puppet_dashboard::params::dashboard_root}/log", '/etc/puppet-dashboard' ]:
    	ensure => directory,
    	recurse => true,
    	recurselimit => '1',
  	}

	file {'/etc/puppet-dashboard/database.yml':
    	ensure => present,
    	content => template('puppet_dashboard/database.yml.erb'),
  	}

	file { "${puppet_dashboard::params::dashboard_root}/config/settings.yml":
    	ensure => present,
    	content => template('puppet_dashboard/settings.yml.erb'),
  	}

	file { "${puppet_dashboard::params::dashboard_root}/config/database.yml":
    	ensure => 'symlink',
    	target => '/etc/puppet-dashboard/database.yml',
  	}

	file { [ "${puppet_dashboard::params::dashboard_root}/log/production.log", "${puppet_dashboard::params::dashboard_root}/config/environment.rb" ]:
    	ensure => file,
   	 	mode => '0644',
  	}

	file { '/etc/logrotate.d/puppet-dashboard':
    	ensure => present,
    	content => template('puppet_dashboard/logrotate.erb'),
    	owner => '0',
    	group => '0',
    	mode => '0644',
  	}

  	exec { 'db-migrate':
    	command => "rake RAILS_ENV=production db:migrate",
    	cwd => "${puppet_dashboard::params::dashboard_root}",
    	path => "/usr/bin/:/usr/local/bin/",
    	creates => "/var/lib/mysql/${dashboard_db}/nodes.frm",
  	}

	mysql::db { "${dashboard_db}":
    	user => $dashboard_dbuser,
    	password => $dashboard_dbpassword,
    	charset => $dashboard_dbcharset,
  	}

	user { $dashboard_user:
		comment => 'Puppet Dashboard',
      	gid => "${dashboard_group}",
      	ensure => 'present',
      	shell => '/sbin/nologin',
      	managehome => true,
      	home => "/home/${dashboard_user}",
  	}

	group { $dashboard_group:
		ensure => 'present',
  	}

	
}
