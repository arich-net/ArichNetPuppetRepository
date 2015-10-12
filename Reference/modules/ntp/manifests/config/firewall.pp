# Class: ntp::config::firewall
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
class ntp::config::firewall() {
	
	class client() {
		@firewall { '200 NTP Client Outgoing':
			proto => 'udp',
			dport => '123',
			chain => 'OUTPUT',
			action => 'accept',
		}
		@firewall { '200 NTP Client Incoming':
			proto => 'udp',
			sport => '123',
			chain => 'INPUT',
			action => 'accept',
		}		
	}
	
	class server() {
		@firewall { '200 NTP Server Incoming':
			proto => 'udp',
			dport => '123',
			chain => 'INPUT',
			action => 'accept',
		}
		@firewall { '200 NTP Server Outgoing':
			proto => 'udp',
			sport => '123',
			chain => 'OUTPUT',
			action => 'accept',
		}		
		@firewall { '201 NTP Client Outgoing':
			proto => 'udp',
			dport => '123',
			chain => 'OUTPUT',
			action => 'accept',
		}
		@firewall { '201 NTP Client Incoming':
			proto => 'udp',
			sport => '123',
			chain => 'INPUT',
			action => 'accept',
		}
	}
	
}