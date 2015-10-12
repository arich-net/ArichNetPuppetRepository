# Class: hosts
#
# This module manages adding records to the /etc/hosts file.
#
# Parameters:
#
# Actions:
#	1) Use facter variables for localhost record? Currently pulling variables from node definition.
#	2) convert host_aliases to allow arrays.
#
# Requires:
#
# Sample Usage:
#	This is a "define" hence you can use this at any scope and within any class to add entried to the file
#	Just make sure you call it using "hosts::add::record"
#
#	To Add Record::
#		hosts::add::record { 'testing':
#		hostname => 'testing.domain.com',
#		hostaliases => 'testing',
#		ip => '4.4.4.4',
#		}
#
#	To Delete Record::
#		Just remove the hosts::add:record entry from the node or class where it is defined.
#
# [Remember: No empty lines between comments and class definition]
class hosts::add() {

	define record($hostname, $hostaliases, $ip) {
    	host { 
			"$hostname":
				ip => "$ip",
				host_aliases => [ "$hostaliases" ];
    	}
    }#define
    
} # class hosts::add

