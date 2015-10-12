# Class: sysfirewall::pre
#
#	Default rules
#
# Parameters:
#
# Actions:
#
# Requires:
#
# Sample Usage:
#	Called from class: sysfirewall, not directly
#
class sysfirewall::pre() {

	Firewall {
		require => undef,
	}
	
	firewall { '000 accept all icmp':
		proto   => 'icmp',
		action  => 'accept',
		tag     => 'sysfirewall::pre',
	}
	
	firewall { '001 accept all to lo interface':
		proto   => 'all',
		iniface => 'lo',
		action  => 'accept',
		chain => 'INPUT',
		tag     => 'sysfirewall::pre',
	}
	
	firewall { '002 accept all from lo interface':
		proto   => 'all',
		outiface => 'lo',
		action  => 'accept',
		chain => 'OUTPUT',
		tag     => 'sysfirewall::pre',
	}
	  
	firewall { '003 accept related established rules':
    	proto   => 'all',
    	state   => ['RELATED', 'ESTABLISHED'],
    	action  => 'accept',
    	chain => 'OUTPUT',
    	tag     => 'sysfirewall::pre',
	}
	
}
