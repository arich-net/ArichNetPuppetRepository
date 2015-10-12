# Class: motd
#
# This module manages and distributes motd
#
# Parameters:
#
# Actions:
#
# Requires:
#   
# Sample Usage:
#
#  include motd
#
#  /etc/motd is sourced as a template first from the environment module then
#  fails back to default stored in core module
#
# [Remember: No empty lines between comments and class definition]
class motd {
	
		file { "/etc/motd":
		ensure => present,
		links => follow, # Just incase /etc/motd is symlinked somewhere else.
		path => $operatingsystem ? {
			default => "/etc/motd",
		},
		mode => 600, owner => root, group => root,
		content => inline_template(
			file(
				"/etc/puppet/environments/$environment/templates/motd/motd.erb",
				"/etc/puppet/modules/motd/templates/motd.erb" # Using inline_template this needs to be full path
			)
		),
	}
	
	
}
