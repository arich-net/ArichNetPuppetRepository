# Class: foreman::install
#
# This class manages foreman
#
# Parameters:
#
# Actions:
#
# Requires:
#	[*mysql*]
#	[*mysql::server*]
#	[*require mysql::ruby*]
#
# Sample Usage:
#
#
# [Remember: No empty lines between comments and class definition]
class foreman::install() {
include foreman::repo::foreman

	package{"foreman":
    	ensure => '1.1.1+ubuntu1',
    	require => [Class["foreman::repo::foreman"], Exec['apt-get_update']],
    	notify => Class["foreman::service"],
  	}
	
}