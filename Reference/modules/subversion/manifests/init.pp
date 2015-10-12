# Class: subversion
#
# This module manages subversion package
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
#	1) add define to checkout, export, update repo's.
#	2) add define to add repositories? 
#
# Requires:
#
# Sample Usage:
#
# [Remember: No empty lines between comments and class definition]
class subversion{
	package { "subversion":
		ensure => latest,
	}
}