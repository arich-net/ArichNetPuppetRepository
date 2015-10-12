# Class: logrotate
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
#	Use logrotate::file define to setup files
#
class logrotate() {
	
	class { 'logrotate::params': }
	class { 'logrotate::install': }
	class { 'logrotate::config': }

	Class['logrotate::params'] -> Class['logrotate::install'] -> Class['logrotate::config']
  
}