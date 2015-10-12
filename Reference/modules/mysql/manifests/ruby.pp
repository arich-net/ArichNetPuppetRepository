# Class: mysql::ruby
#
# installs the ruby bindings for mysql
#
# Parameters:
# [*ensure*] - ensure state for package.
# can be specified as version.
# [*package_name*] - name of package
#
# Actions:
#
# Requires:
#
# Sample Usage:
#
class mysql::ruby( $ensure = installed, $package_name = $::mysql::params::ruby_mysql_package_name) {
	include mysql::params
	
	package{'ruby-mysql':
    	name => $package_name,
    	ensure => $ensure,
  	}
  
}