# Class: logrotate::config
#
# Manages logrotate pkg and logrotate.d/*
#
# Operating systems:
#	:Working
#
# 	:Testing
#
# Parameters:
#
# Actions:
#	1) Perhaps add a force and purge on the /etc/logrotate.d/* and manage all via puppet?
#
# Requires:
#
# Sample Usage:
#	include logrotate within node or seperate class.
#
class logrotate::config() {

	file { $logrotate::params::confdir:
		owner   => root,
		group   => root,
		ensure  => directory,
		require => Class['logrotate::install'],
	}
}