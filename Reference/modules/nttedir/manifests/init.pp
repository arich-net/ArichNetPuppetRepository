# Class: nttedir
#
# This module manages /usr/local/ntte & c:\ntte
#
# *IMPORTANT NOTE*
#
#	This module is used for the global, core scripts/files to be deployed to EVERY host that has this class
#	defined.
#	This class should be defined in bootstrap and then included into EVERY managed system.
#
#	$envsource is used incase you specifcally do not want to distribute your environment files but want
#	to store them in revision control.
#
# Parameters:
#	$envsource = undef(false)/true
#
# Actions:
#
# Requires:
#
# Sample Usage:
#
#	include nttedir
#
# [Remember: No empty lines between comments and class definition]
class nttedir( $envsource = undef ) {

	file { "/usr/local/ntte":
		path => $::operatingsystem ? {
			'windows' => "c:/ntte",
			default => "/usr/local/ntte",
			},
		ensure  => directory,
		owner => root,
    	group => root,
#	   	mode => 0755,
		recurse => true,
		purge => true,
		force => true, # Forces a removal if ensure => absent
		backup => false,
		source => "puppet:///modules/nttedir"
        }

	# if $envsource == false|undef then the above file resouce will take care of the purge process
	# and remove any files previously deployed with the below resource. 
	if $envsource == true {
		file { "/usr/local/ntte/$::environment":
        	path => $::operatingsystem ? {
				'windows' => "c:/ntte/$::environment",
				default => "/usr/local/ntte/$::environment",
			},
			ensure  => directory,
			owner => root,
			group => root,
#           mode => 0755,
			recurse => true,
			purge => true,
			force => true,
			backup => false,
			source => "puppet:///files-environment/$::environment/files/nttedir"
		}

	}
        

}
