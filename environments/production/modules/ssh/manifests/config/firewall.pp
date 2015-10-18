# Class: ssh::config::firewall
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
class ssh::config::firewall() {
	
	# Client port we will default to use standard TCP/22
	class client() {
		@firewall { "200 $name TCP Outgoing":
			proto => 'tcp',
			dport => '22',
			chain => 'OUTPUT',
			action => 'accept',
			state   => ['NEW', 'RELATED', 'ESTABLISHED'],
		}
		@firewall { "200 $name TCP Incoming":
			proto => 'tcp',
			sport => '22',
			chain => 'INPUT',
			action => 'accept',
			state   => ['RELATED', 'ESTABLISHED'],
		}		
	}
	
	# We pass the $ssh_listenport from ssh::server.
	class server($ssh_listenport) {
		@firewall { "200 $name TCP Incoming":
			proto => 'tcp',
			dport => $ssh_listenport,
			chain => 'INPUT',
			action => 'accept',			
		}
		
		@firewall { "200 $name TCP Outgoing":
			proto => 'tcp',
			sport => $ssh_listenport,
			chain => 'OUTPUT',
			action => 'accept',			
		}
	}
	
}