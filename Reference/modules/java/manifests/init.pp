# Class: java
#
# This module manages the Java runtime package
#
# Parameters:
#	$distribution = jre/jdk
#	$version = installed/latest
#
# Actions:
#	1) implement redhat support
#
# Requires:
#
# Sample Usage:
#	  class { 'java': distribution => 'jdk', version => 'latest', }
#	  class { 'java': }
#
# [Remember: No empty lines between comments and class definition]
class java($distribution = 'jre',$version = 'installed') {

	case $::operatingsystem {
		#centos, redhat, oel: {

		#}
		debian, ubuntu: {
		
			$distribution_debian = $distribution ? {
        		jdk => 'openjdk-6-jdk',
        		jre => 'openjdk-6-jre',
      		}
   			package { 'java':
    			ensure => $version,
    			name => $distribution_debian,
  			}
		}
		default: {
      		fail("class java - operatingsystem $operatingsystem is not supported")
		}

  }

}