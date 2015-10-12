# Class: sysfirewall::post
#
#	Drop all rule appended to the pre and custom rules.
#
# Parameters:
#	Ensure all firewall resources in this class have "before => undef" as this ensures the
#	global firewall resource dependency of before => Class['sysfirewall::post'] is nulled, and
#	therefore not creating a dependency loop.
#
# Actions:
#
# Requires:
#
# Sample Usage:
# 	Called from class: sysfirewall, not directly
#
class sysfirewall::post() {

	firewall { '995 log dropped packets':
		jump       => 'LOG',
		log_level  => '4',
		log_prefix => '[IPTABLES] dropped - ',
		proto      => 'all',
		before  => undef,
	}
        
	firewall { '999 OUTPUT drop all':
		proto   => 'all',
		action  => 'drop',
		chain => 'OUTPUT',
		before  => undef,
	}
	
	firewall { '999 INPUT drop all':
		proto   => 'all',
		action  => 'drop',
		chain => 'INPUT',
		before  => undef,
	}
	
	firewall { '999 FORWARD drop all':
		proto   => 'all',
		action  => 'drop',
		chain => 'FORWARD',
		before  => undef,
	}

}