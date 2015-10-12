# Class: foreman::config
#
# Manages the foreman service
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
class foreman::config() {
	
	case $::operatingsystem {
		'centos','redhat','oel': {
        	file { '/etc/sysconfig/foreman':
        		ensure => present,
          		content => template('foreman/sysconfig.erb'),
          		owner => '0',
          		group => '0',
          		mode => '0644',
          		require => Package[foreman],
          		before => Service[foreman],
        	}
      	}
      	'debian','ubuntu': {
        	file { '/etc/default/foreman':
        		ensure => present,
          		content => template('foreman/default.erb'),
          		owner => '0',
          		group => '0',
          		mode => '0644',
          		require => Package[foreman],
          		before => Service[foreman],
        		}
      		}
		}
	
	
	Cron {
    	require => User["$foreman::params::user"],
    	user => $foreman::params::user,
    	environment => "RAILS_ENV=${foreman::params::environment}",
  	}

	file {"/etc/foreman/settings.yaml":
    	content => template("foreman/settings.yaml.erb"),
    	notify => Class["foreman::service"],
    	owner => $foreman::params::user,
    	require => [User["$foreman::params::user"], Package["foreman"]],
	}


	file {"/etc/foreman/database.yml":
		content => template("foreman/database.yml.erb"),
		notify => Class["foreman::service"],
		owner => $foreman::params::user,
		require => [User["$foreman::params::user"], Package["foreman"]],
	}

	file { $foreman::params::app_root:
    	ensure => directory,
    	require => Package["foreman"],
  	}

  	user { $foreman::params::user:
    	shell => "/sbin/nologin",
    	comment => "Foreman",
    	ensure => "present",
    	home => $foreman::params::app_root,
    	require => Class["foreman::install"],
  	}
  
	# cleans up the session entries in the database
  	# if you are using fact or report importers, this creates a session per request
  	# which can easily result with a lot of old and unrequired in your database
  	# eventually slowing it down.
  	cron{"clear_session_table":
    	command => "(cd $foreman::params::app_root && rake db:sessions:clear)",
    	minute => "15",
    	hour => "23",
	}

  	if $foreman::params::reports { include foreman::config::reports }
  	if $foreman::params::enc { include foreman::config::enc }
  	if $foreman::params::passenger { include foreman::config::passenger }
}