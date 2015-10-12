# Class: rails
#
# This module manages rails
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
class rails() {
	case $::operatingsystem {
		#debian: { include rails::debian } # if distro has a specific package or config
		#ubuntu: { include rails::ubuntu } # if distro has a specific package or config
		default: { include rails::gem }
	}
}
