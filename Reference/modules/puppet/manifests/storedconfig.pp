# Class: puppet::storedconfig
#
# This module manages setting up stored config on puppet masters
#
# Parameters:
#	These params are passwd from a call inside puppet:puppeteer, and then passed to the define mysql::db
#
#	$storedconfig_db = DB name
#	$storedconfig_dbuser = DB user
#	$storedconfig_dbpasswd = DB passwd
#
# Actions:
#
# Requires:
#	puppet::puppeteer = this is called from this class.
#
# Sample Usage:
#
# [Remember: No empty lines between comments and class definition]
class puppet::storedconfig( $storedconfig_db,
							$storedconfig_dbuser, 
							$storedconfig_dbpasswd 
) {
	
	require mysql
	require mysql::server
	require mysql::ruby
	require rails
	
	mysql::db { "${storedconfig_db}":
		user => $storedconfig_dbuser,
        password => $storedconfig_dbpasswd,
	}
}