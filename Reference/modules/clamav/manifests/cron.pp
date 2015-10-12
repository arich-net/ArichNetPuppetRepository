# Class: clamav::cron
#
# Manages the cron entry for clamav
#
# Operating systems:
#	:Working
#		Ubuntu 10.04
#
# 	:Testing
#
# Parameters:
#	$ensure = present/absent
#	$command = command to run, defaults to $clamav::params::cron_command
#	$hour = hour to run command, defaults to $clamav::params::cron_hour
#	$minute = minute to run command, defaults to $clamav::params::cron_minute
#
# Actions:
#
# Requires:
#
# Sample Usage:
#	This is not called directly, but via class: clamav when param $clamav_runasdaemon = false
#
class clamav::cron( $ensure, $command, $hour, $minute ) inherits clamav::params {
	
	cron { "clamav":
		ensure  => $ensure,
		command => $command,
		user => root,
		hour => $hour,
		minute => $minute,
	}

}