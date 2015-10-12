# Class: managed_interface
#
# This class maintains the specified interface configuration
#
# Operating systems:
#	:Working
#		Ubuntu 10.04
#		RHEL5
# 	:Testing
#
#
# Parameters:
#	$device
#		Set to "present" or "absent"
#
#   $device
#       The name of the network device (e.g. eth0/sit0/ppp0)
#
#   $ipaddr
#       The IP address to assign to the interface
#
#   $netmask
#       The Subnet Mask which should be assigned to the interface
#
#   $up
#       Should the interface come up on boot? (optional)
#
#   $network
#       The address for the start of this subnet (optional)
#
#   $hwaddr
#       The MAC Address for the ethernet device (optional)
#
#   $gateway
#       The default gateway to be configured. Remember that only the last configured gateway will be used. (optional)
#
# Actions:
#   Ensures that the appropriate python libraries are installed and ensures that the correct source code revisions are installed via git
#
# Sample Usage:
#
#   networking::interface::managed_interface{ "lo":
#		 ensure   => "present",
#       device  => "lo",
#       ipaddr  => "127.0.0.1",
#       netmask => "255.0.0.0",
#       hwaddr  => "00:1d:09:fa:93:6a",
#       up  => true,
#   }
#
class networking::interfaces inherits networking {
	

define managed_interface( $ensure, 
	                       $device, 
	                       $ipaddr, 
	                       $netmask=undef, 
	                       $up=true, 
	                       $network="", 
	                       $hwaddr="",
	                       $gateway="",
	                       $restart = false
) {
include networking
#
# Nasty hack for integration with build data output 
# and the ability to pass CIDR notations to this define for parsing.
#
# We need to improve the netmask function in order to process an IP more efficiently and pass it back
#
$ip_a=inline_template('<%= ipaddr.split("/")[0] %>')
$subnet_a=inline_template('<%= ipaddr.split("/")[1] %>')

if $subnet_a == undef {
$netmask_final = $netmask
} else {
$netmask_final = netmask($ipaddr)
}

    ##
    ## Handle RedHat derivatives
    ##
    if ($operatingsystem == redhat) or ($operatingsystem == centos) or ($operatingsystem == fedora) {
        if ($up) {
            $onBoot = "yes"
        } else {
            $onBoot = "no"
        }

        augeas { "main-$device":
            context => "/files/etc/sysconfig/network-scripts/ifcfg-$device",
            changes => [
                "set DEVICE $device",
                "set BOOTPROTO none",
                "set ONBOOT $onBoot",
                "set NETMASK $netmask_final",
                "set IPADDR $ip_a",
            ],
        }

        if ($network!="") {
            augeas { "network-$device":
                context => "/files/etc/sysconfig/network-scripts/ifcfg-$device",
                changes => [
                    "set NETWORK $network",
                ],
            }
        }

        if ($hwaddr!="") {
            augeas { "mac-$device":
                context => "/files/etc/sysconfig/network-scripts/ifcfg-$device",
                changes => [
                    "set HWADDR $hwaddr",
                ],
            }
        }

        if ($gateway!="") {
            augeas { "gateway-$device":
                context => "/files/etc/sysconfig/network",
                changes => [
                    "set GATEWAY $gateway",
                ],
            }
        }

        if $up {
            exec {"ifup-$device":
                command => "/sbin/ifup $device",
                unless  => "/sbin/ifconfig | grep $device",
                require => Augeas["main-$device"],
            }
        } else {
            exec {"ifdown-$device":
                command => "/sbin/ifconfig $device down",
                onlyif  => "/sbin/ifconfig | grep $device",
            }
        }
    ##
    ## Handle Debian based systems
    ##
    } else {
        if ($operatingsystem == debian) or ($operatingsystem == ubuntu) {
            
            case $ensure {
            	present: {
            augeas { "main-$device" :
                context => "/files/etc/network/interfaces",
                changes => [
                    "set auto[child::1 = '$device']/1 $device",
                    "set iface[. = '$device'] $device",
                    "set iface[. = '$device']/family inet",
                    "set iface[. = '$device']/method static",
                    "set iface[. = '$device']/address $ip_a",
                    "set iface[. = '$device']/netmask $netmask_final",
                ],
                notify => $restart? {
                	true => Exec["restart-networking"],
                	default => undef
                }
            }

            if ($hwaddr!="") {

                augeas { "mac-$device" :
                    context => "/files/etc/network/interfaces",
                    changes => [
                        "set iface[. = '$device']/hwaddress $hwaddr",
                    ],
                    require => Augeas["main-$device"],
                	notify => $restart? {
                		true => Exec["restart-networking"],
                		default => undef
                	}
                }
            }

            if ($network!="") {

                augeas { "network-$device" :
                    context => "/files/etc/network/interfaces",
                    changes => [
                        "set iface[. = '$device']/network $network",
                    ],
                    require => Augeas["main-$device"],
					notify => $restart? {
                		true => Exec["restart-networking"],
                		default => undef
                	}
                }
            }

            if ($gateway!="") {

                augeas { "network-$device" :
                    context => "/files/etc/network/interfaces",
                    changes => [
                        "set iface[. = '$device']/gateway $gateway",
                    ],
                    require => Augeas["main-$device"],
                	notify => $restart? {
                		true => Exec["restart-networking"],
                		default => undef
                	}
                }
            }
            
            } # end present statment
            absent: {
            	augeas { "main-$device" :
                	context => "/files/etc/network/interfaces",
                	changes => [
                    	"rm auto[child::1 = '$device'] $device",
                    	"rm iface[. = '$device'] $device",
                	],
                	notify => $restart? {
                		true => Exec["restart-networking"],
                		default => undef
                	}
            	}	
            } # end absent statment
            
            } # end case statment        

            if $up {
                exec {"/sbin/ifup $device":
                    command => "/sbin/ifup $device",
                    unless  => "/sbin/ifconfig | grep $device",
                    refreshonly => true,
                }
            } else {
                exec {"/sbin/ifdown $device":
                    command => "/sbin/ifconfig $device down",
                    onlyif  => "/sbin/ifconfig | grep $device",
                    refreshonly => true,
                }
            }
        }
    }
}
}