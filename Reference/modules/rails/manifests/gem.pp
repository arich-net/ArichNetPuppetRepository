# Class: rails::gem
#
# This module manages rails::gem (rails via gem), used mainly for puppet and the stored configuration DB
#
# Parameters:
#	
# Actions:
#
# Requires:
#
# Sample Usage:
#
# [Remember: No empty lines between comments and class definition]
class rails::gem() {
	include ruby::dev
	package { rails: 
		ensure => '2.3.5',
		provider => gem,
		require => Package['rubygems'], 
	}
}
