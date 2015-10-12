# Class: djbdns::params
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
class djbdns::params() {

	case $::operatingsystem {
		debian: {
        	$dnscache_basedir = "/etc/dnscache"
        	$tinydns_basedir = "/etc/tinydns"
        }
        ubuntu: {
        	$dnscache_basedir = "/etc/dnscache"
        	$tinydns_basedir = "/etc/tinydns"
        }
        default: { 

		}
    }
}