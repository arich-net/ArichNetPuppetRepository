# Class: puppet::config::firewall
#
# 	Configures firewall rules for puppet.
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
class puppet::config::firewall() {
	
	class client() {
	
		@firewall { "200 $name TCP 8140 Outgoing":
			proto => 'tcp',
			dport => '8140',
			chain => 'OUTPUT',
			action => 'accept',
			state   => ['NEW', 'RELATED', 'ESTABLISHED'],
		}
		@firewall { "200 $name TCP 8140 Incoming":
			proto => 'tcp',
			sport => '8140',
			chain => 'INPUT',
			action => 'accept',
			state   => ['RELATED', 'ESTABLISHED'],
		}
		@firewall { "200 $name UDP 8140 Outgoing":
			proto => 'udp',
			dport => '8140',
			chain => 'OUTPUT',
			action => 'accept',
		}
		@firewall { "200 $name UDP 8140 Incoming":
			proto => 'udp',
			sport => '8140',
			chain => 'INPUT',
			action => 'accept',
		}
		
	}
	
	class master() {
		@firewall { "200 $name TCP 8140 Incoming":
			proto => 'tcp',
			sport => '8140',
			chain => 'INPUT',
			action => 'accept',
			state   => ['NEW', 'RELATED', 'ESTABLISHED'],
		}
	}
}