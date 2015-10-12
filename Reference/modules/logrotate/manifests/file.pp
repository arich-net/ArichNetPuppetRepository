# define: logrotate::file
#
# Manages logrotate.d/*
#
# Operating systems:
#	:Working
#
# 	:Testing
#
# Parameters:
#	log = array of log files, can just be one. (required)
#	options = array of options to include. (optional, defaults are set)
#	prerotate = command to execute pre rotation. (optional)
#	postrotate = command to execute post rotation. (optional)
#
# Actions:
#
# Requires:
#
# Sample Usage:
#	Include logrotate within node or seperate class.
#	Use a class or at node level use the define to create logrotate files
#
# 	logrotate::file { 'testapp':
#  		postrotate => "/etc/init.d/testapp reload > /dev/null",
#  		log        => [ '/var/log/testapp1.log', '/var/log/testapp2.log' ],
#  		options    => [ 'weekly', 'compress', 'rotate 52', 'missingok' ]
#  	}
#
define logrotate::file(	 	$source = "${logrotate::params::confdir}/${name}",
							$log,
							$options = [ 'weekly', 'compress', 'rotate 7', 'missingok' ],
							$prerotate = 'NONE',
							$postrotate = 'NONE'
) {

	file { "${logrotate::params::confdir}/${name}":
		ensure  => present,
		owner   => root,
		group   => root,
		mode    => 644,
		content => template('logrotate/logrotate.erb'),
		require => Class['logrotate::config'],
	}
 
}