# Class: foreman
#
# This class manages foreman
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
class foreman() {
	include foreman::params
	include foreman::install
	include foreman::config
	include foreman::service	
}