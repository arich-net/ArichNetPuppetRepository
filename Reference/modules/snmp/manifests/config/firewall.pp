# Class: snmp::config::firewall
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
class snmp::config::firewall() {
	
	@firewall { "200 $name TCP Incoming":
		proto => 'udp',
		dport => '161',
		chain => 'INPUT',
		action => 'accept',		
	}
	@firewall { "200 $name TCP Outgoing":
		proto => 'udp',
		sport => '161',
		chain => 'OUTPUT',
		action => 'accept',		
	}		
		
}