# Class: c356106::routes
#
# This class maintains the persistent static routes for environment c356106
#
# Operating systems:
#	:Working
#
# 	:Testing
#		Ubuntu 10.04
#		RHEL5
#
# Parameters:
#
# Actions:
#
# Sample Usage:
#	We cannot use this yet as we need to reliably identify the subnet we are adding a route for and the 
#	interface it corrosponds to, as we need to write to route-<int> (redhat> or interfaces (debian).
#
class c356106::routes($ensure='present') {


	case $hostname {
		/^e{1}..33.{5}$/: { $gw = '192.168.231.254' }
		/^e{1}..00.{5}$/: { $gw = '192.168.231.254' }
		/^e{1}..03.{5}$/: { $gw = '192.168.231.254' }
		default: { notice("Unrecognized hostname from facter") }
    }
    
	case $operatingsystem {
    	'centos', 'redhat', 'fedora': {
			$splunk_forwarder_pkg = 'splunk-4.2.3-105575-linux-2.6-intel.deb'
		}
    	'Ubuntu', 'debian': {
			$splunk_forwarder_pkg = 'splunk-4.2.3-105575-linux-2.6-intel.deb'
		}
	}


	networking::routes::managed_route{ "192.168.0.0/16":
		ensure   => "present",
		network => "192.168.0.0",
		subnet => "255.255.0.0",
		gateway => "192.168.231.254",
	}
   	
}