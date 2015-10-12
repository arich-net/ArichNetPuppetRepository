# Class: logrotate::install
#
# Operating systems:
#	:Working
#
# 	:Testing
#
# Parameters:
#
# Actions:
#
# Requires:
#
# Sample Usage:
#
class logrotate::install() {

	package { $logrotate::params::pkg:
    	ensure => installed,
    	require => Class['logrotate::params'],
	}
  
}