# Class: mcollective::config::firewall
#
# Parameters:
#
# Actions:
#
# Requires:
#	$name is passed from mcollective::server and looped to create multiple resources
#
# Sample Usage:
#
# [Remember: No empty lines between comments and class definition]
class mcollective::config::firewall() {
	
	class client() {

	}
	
	define server() {
		@firewall { "200 MCollective TCP $name outgoing":
			proto => 'tcp',
			destination => $name,
			dport => $stompport,
			chain => 'OUTPUT',
			action => 'accept',
		}
		@firewall { "200 MCollective TCP $name Incoming":
			proto => 'tcp',
			sport => $stompport,
			chain => 'INPUT',
			action => 'accept',
		}
	}
	
}