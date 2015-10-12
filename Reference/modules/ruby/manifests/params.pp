# Class: ruby::params
#
# This module manages ruby params
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
class ruby::params() {

 case $::operatingsystem {
    "centos": {
      $ruby_dev="ruby-devel"
    }
    "ubuntu": {
      $ruby_dev= [ "ruby-dev", "rake", "irb" ]
    }
 }
  
}
