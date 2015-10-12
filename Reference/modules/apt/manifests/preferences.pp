# Define: apt::preferences
#
# This module manages apt preferences for ubuntu & debain
#
# Operating systems:
#	:Working
#		Ubuntu 8.04/10.04
#		Debian 4/5
# 	:Testing
#
# Parameters:
#	$ensure = Add or remove entry
#	$package = Which package to pin (if different to $name)
#	$pin = pin value, either release or version
#	$pin_value = the release i.e oneiric or the package version
#	$priority = pri value
#
# Actions:
#	1) slighty bad design with augeas, could do with rewrite, but its working :)
#
# Requires:
#	class apt
#
# Sample Usage: 
#	apt::preferences { 'bash':
#		ensure => 'present',
#		package => 'bash',
#		pin => 'release',
#		pin_value => 'oneiric',
#		priority => '950',
#	}
#
# [Remember: No empty lines between comments and class definition]
define apt::preferences($ensure="present", $package="$name", $pin, $pin_value, $priority) {


	if $pin == "release" {
		$pin_second = "a"
	}elsif $pin == "version" {
		$pin_second = "version"	
	}

	#These chars shouldn't be used but attempt to replace
	#$apackage = regsubst($package, '\.', '-', 'G')

	# apt support preferences.d since version >= 0.7.22 else we use augeas to maintain apt/preferences
	case $::lsbdistcodename {
		/lucid|squeeze/ : {
			file {"/etc/apt/preferences.d/$package":
				ensure => $ensure,
				owner => root,
				group => root,
				mode => 644,
				content => template("apt/preferences.erb"),
				before => Exec["apt-get_update"],
				notify => Exec["apt-get_update"],
			}
		}
	default: {
		case $ensure {
			present: {
				# We need to add the node to the tree first otherwise the "preferences-$package" will fail
				# as it will not be able to find [Package = '$package']
				augeas { "preferences-add-$package" :
					context => "/files/etc/apt/preferences",
					changes => [
						# We use "00" as it will add to the end of the file
						# it will then be a sequential number once you view the tree again.
						"set /files/etc/apt/preferences/00/Package '$package'",
					],
					onlyif => "match /files/etc/apt/preferences/*[Package = '$package'] size == 0",
					notify  => Exec["apt-get_update"],
					before => Augeas["preferences-update-$package"],
				}
				
				augeas { "preferences-update-$package" :
					context => "/files/etc/apt/preferences",
					changes => [
						"set /files/etc/apt/preferences/*[Package = '$package']/Pin '$pin'",
						"set /files/etc/apt/preferences/*[Package = '$package']/Pin/$pin_second '$pin_value'",
						"set /files/etc/apt/preferences/*[Package = '$package']/Pin-Priority '$priority'",
					],
					notify  => Exec["apt-get_update"],
				}
				
			} #Present
			absent: {
				augeas { "preferences-$package" :
					context => "/files/etc/apt/preferences",
					changes => [
						"rm /files/etc/apt/preferences/*[Package = '$package']",
					],
					notify  => Exec["apt-get_update"],
				}
				
			} #Absent
		} #case $ensure

   
    }
  }
}