# Class: sudo
#
# This module manages sudo package and sudoers file
#
# Operating systems:
#	:Working
#		Ubuntu 10.04
#		RHEL5
# 	:Testing
#
# Parameters:
#
# Actions:
#	1) Move sudoers file into environment specific and convert to parameterized class. DONE
#
# Requires:
#
# Sample Usage:
#	/etc/sudoers is sourced as a template first from the environment module then
#  fails back to default stored in core module
#
# [Remember: No empty lines between comments and class definition]
class sudo( $sudoers = undef ) {

  	if $sudoers {
		$mysudoers = $sudoers
	} else {
		$mysudoers = 'sudoers.erb'
	}
	
	package { sudo: ensure => latest }

	file { "/etc/sudoers":
		owner => root,
		group => root,
		mode => 440,
		#content => template("sudo/sudoers.erb"),
		content => inline_template(
			file(
				"/etc/puppet/environments/$::environment/templates/sudo/$mysudoers",
				"/etc/puppet/modules/sudo/templates/sudoers.erb" # Using inline_template this needs to be full path
			)
		),
		require => Package["sudo"],
	}
	
}