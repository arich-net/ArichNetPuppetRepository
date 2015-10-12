# Class: bootstrap::networking
#
#	Host records are configured as during post install we inject a few defaults,
#	and therefore facter will know about these.
#
#	1) Configures networking interfaces
#	2) We add the host entries here as the data coming from nexus is not in a nice format
#		and in order to grab eth0/eth1 we need to do it here when its passed to create_resources
#
# hiera expects format :
#
# Parameters:
#
# Actions:
#
# Requires:
#
# Sample Usage:
#
#	include bootstrap::networking
#
# [Remember: No empty lines between comments and class definition]
class bootstrap::networking() {

# Calling hosts will purge any non-defined resources
class {'hosts': add_defaults => false, purge => false }

$hiera_interfaces = hiera(interfaces)
$hiera_interfaces_data = $hiera_interfaces["data"]["interfaces"]

create_resources('bootstrap::networking::configure_interface', $hiera_interfaces_data)

	# FQDN, is really just the dns arecord without the doamin "evl0000001-pip", 
	# but NBoss name it this way in the API
	define configure_interface( $name=undef,
		                         $address=undef,  
		                         $fqdn=undef,
		                         $mac_address=undef
	) {
		
		
		$hiera_connectivity = hiera(connectivity)
		$hiera_connectivity_data = $hiera_connectivity["data"]["connectivity"]
		$hiera_connectivity_data_default_gateway = $hiera_connectivity_data["default_gateway_ipv4"]
		
		
		# Strip CIDR notation off for use in /etc/hosts
		$ip_addr=inline_template('<%= address.split("/")[0] %>')
			
		# When using virtual adapters we will rename,
		# not ideal but working.
		$name_real = $name ? {
			'Network adapter 1'		=> 'eth0',
			'Network adapter 2'		=> 'eth1',
			'Network adapter 3'		=> 'eth2',
			'Network adapter 4'		=> 'eth3',
			'Network adapter 5'		=> 'eth4',
			'Network adapter 6'		=> 'eth5',
			default					=> $name
		}
		
		
		# Set default host records
		if $name_real == 'eth0' {
			hosts::add::record { $name_real:
				hostname => $::fqdn,
				hostaliases => $::hostname,
				ip => $ip_addr,
			}
		}
		
		if $name_real == 'eth1' {
			hosts::add::record { $name_real:
				hostname => "${fqdn}.oob.${::domain}",
				hostaliases => "${::fqdn}",
				ip => $ip_addr,
			}
		}
		
		networking::interfaces::managed_interface{ $name_real:
			ensure   => present,
			device  => $name_real,
			ipaddr  => $address,
			hwaddr  => $mac_address,
			gateway => $name_real ? {
							eth0 => $hiera_connectivity_data_default_gateway,
							default => undef
						},
			up  => true,
			restart => false,
		}
		
	
	}


} 