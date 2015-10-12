# Class: managed_routes
#
# This class maintains the persistent static routes
#
# Operating systems:
#	:Working
#		Ubuntu 10.04
#		RHEL5
# 	:Testing
#
#
# Parameters:
#	$ensure
#		Set to "present" or "absent"
#
#   $network
#       The network xxx.xxx.xxx.xxx
#
#   $subnet
#       subnet mask of the defined network, no notations (xxx.xxx.xxx.xxx)
#
#   $gateway
#       The route gateway
#
# Actions:
#   1) Ensure route is up when $ensure is present and ensure route is down when absent etc.
#   2) Multiple routes for redhat? maybe add a parameter for the define $sequence.
#   3) Shall we just "ip route add" rather then restart networking? create new exec for route additions/deletions.
#	4) Allow multiple routes, modify augeas sets, i.e last()+1 (redhat)
#
#   *COMPLETE* 
#	1) Allow multiple routes, modify augeas sets, i.e last()+1 (ubuntu)
#
# Sample Usage:
#
#   networking::routes::managed_route{ "192.168.0.0/16":
#		 ensure   => "present",
#       network => "192.168.0.0",
#       subnet => "255.255.0.0",
#       gateway => "192.168.231.254",
#       interface => "eth1",
#   }
#
class networking::routes inherits networking {

define managed_route($ensure, $network, $subnet, $gateway, $interface) {

# To give access to functions
include networking
	
    ##
    ## Handle RedHat derivatives
    ##
    if ($operatingsystem == redhat) or ($operatingsystem == centos) or ($operatingsystem == fedora) {
		case $ensure {
			present: {
				
				augeas { "route-$name":
					lens => "Shellvars.lns",
					incl => "/etc/sysconfig/network-scripts/route-*",
            		context => "/files/etc/sysconfig/network-scripts/route-$interface",
            		changes => [
            			"set ADDRESS0 $network",
                		"set NETMASK0 $subnet",
                		"set GATEWAY0 $gateway",
            		],
					notify  => Exec["restart-networking"],
        		}
        		
        		
			} # End present statement
			absent: {
				
				augeas { "route-$name":
					lens => "Shellvars",
					incl => "/etc/sysconfig/network-scripts/route-*",
            		context => "/files/etc/sysconfig/network-scripts/route-$interface",
            		changes => [
                		"rm ADDRESS0 $network",
                		"rm NETMASK0 $subnet",
                		"rm GATEWAY0 $gateway",
            		],
            		notify  => Exec["restart-networking"],
        		}
        		
        		
			} # End absent statement
		}
        

    ##
    ## Handle Debian based systems
    ##
    } else {
        if ($operatingsystem == debian) or ($operatingsystem == ubuntu) {
            
            case $ensure {
            	present: {
            		augeas { "route-$name" :
                		context => "/files/etc/network/interfaces",
                		changes => [
                			"set auto[child::1 = '$interface']/1 $interface",
                			"set iface[. = '$interface']/post-up[last()+1] 'ip route add $network/$subnet via $gateway'",
                    		"set iface[. = '$interface']/pre-down[last()+1] 'ip route delete $network/$subnet via $gateway'",
                		],
                		onlyif => "match iface[. = '$interface']/post-up[. = 'ip route add $network/$subnet via $gateway'] size == 0",
                		notify  => Exec["restart-networking"],
            		}
           		} # end present statment
            	absent: {
            		augeas { "route-$name" :
                		context => "/files/etc/network/interfaces",
                		changes => [
                    		"rm iface[. = '$interface']/post-up[. = 'ip route add $network/$subnet via $gateway']",
                    		"rm iface[. = '$interface']/pre-down[. = 'ip route delete $network/$subnet via $gateway']",
                		],
                		notify  => Exec["restart-networking"],
            		}	
            	} # end absent statment
            } # end case statment        

        }
    }
}
}