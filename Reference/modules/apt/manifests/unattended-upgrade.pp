# Class: apt::unattended-upgrade
#
# This module manages apt unattended upgrades on ubuntu
#
# Operating systems:
#	:Working
#		Ubuntu 8.04/10.04
# 	:Testing
#
# Parameters:
#
# Actions:
#	1) We still need to manage switching unattended-upgrades on within another file.
#	1) Upgrade to support debian, use augeas within case statment?
#
# Requires:
#
# Sample Usage:
#
# [Remember: No empty lines between comments and class definition]
class apt::unattended-upgrades() {

	package {"unattended-upgrades":
		ensure => present,
	}

# Upgrade for debian?	
#	case $::lsbdistid {
#    'Debian': {
#      apt::conf{'50unattended-upgrades':
#        ensure => present,
#        content => template("apt/unattended-upgrades.${lsbdistcodename}.erb"),
#      }
#    }

	apt::conf{'50unattended-upgrades':
		ensure => present,
		content => template("apt/50unattended-upgrades.erb"),
	}
  
}
