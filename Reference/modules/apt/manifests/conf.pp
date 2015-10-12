# Define: apt::conf
#
# This module manages apt.conf.d/*
#
# Operating systems:
#	:Working
#		Ubuntu 8.04/10.04
#		Debian 4/5
# 	:Testing
#
# Parameters:
#	$ensure = Add or remove entry
#	$content = undef/template or direct soure
#	$source = a file from puppet:// fileserver
#
# Actions:
#	1) Use augeas to modify entries?
#
# Requires:
#
# Sample Usage: 
#	apt::conf { '50unattended-upgrades':
#		ensure => 'present',
#		content => template("apt/50unattended-upgrades.erb"),
#		content => "APT::Periodic::Unattended-Upgrade \"1\";\n",
#		source => "puppet:///files-environment/$environment/files/apt/apt.conf.d/50unattended-upgrades.erb", 
#	}
#
# [Remember: No empty lines between comments and class definition]
define apt::conf($ensure, $content = false, $source = false) {
	
	if $content {
    	file {"/etc/apt/apt.conf.d/$name":
      		ensure => $ensure,
      		content => $content,
      		before => Exec["apt-get_update"],
      		notify => Exec["apt-get_update"],
    	}
  	}

  	if $source {
    	file {"/etc/apt/apt.conf.d/$name":
      		ensure => $ensure,
      		source => $source,
      		before => Exec["apt-get_update"],
      		notify => Exec["apt-get_update"],
    	}
  	}


}