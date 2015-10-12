# Class: hosts
#
# This module manages /etc/hosts
#
# Parameters:
#	$add_defaults = true/false : Add/maintain a defined set of default host entries.
#
# Actions:
#	1) Use facter variables for localhost record? Currently pulling variables from node definition.
#	2) Add define to add and manage records at node scope.
#
# Requires:
#
# Sample Usage:
#	This module will add a localhost entry as well as the primary IP (first interface) to /etc/hosts.
#	Use hosts::add::record if you wish to manage additional entries.
#
# [Remember: No empty lines between comments and class definition]
class hosts( $add_defaults = true,
	          $purge = true	
) {

	resources { 'host': 
    	purge => $purge, 
    	noop => false,
	}

    file { "/etc/hosts":
        ensure => present, 
    }

    Host {
        ensure => present,
        require => File["/etc/hosts"],
    }

	if $add_defaults == true {
	    # localhost and primary IP (according to facter) (usually first interface)
	    host { 
			"localhost.localdomain":
				ip => "127.0.0.1",
				host_aliases => [ 'localhost' ];
			#"$fqdn":
			#	ip => $fqdn ? {
			#		default => "$ipaddress",
			#	},
			#	host_aliases => [ "$hostname" ];
			"$::fqdn":
				ip => "$::ipaddress",
				host_aliases => [ "$::hostname"];
			#"$my_hostname.$my_location.oob.$my_domain":
			#	ip => "$ipaddress_eth1",
			#	host_aliases => [ "$my_hostname.oob"];
	    }
	    
	    # Backup, variables used from class location_londen01 scope
	    #host { "$my_backup_master_host":
	    #	ip => "$my_backup_master_ip",
	    #	host_aliases => [ "$my_backup_master_host_alias" ];
	    #}
    }
    
} # class hosts

