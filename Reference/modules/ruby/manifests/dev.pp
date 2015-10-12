# Class: ruby::dev
#
# This module manages ruby dev libs
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
class ruby::dev {
  require ruby
  include ruby::params

  package { $ruby::params::ruby_dev:
    ensure => installed,
  }

}
