# Class: splunk::config::firewall
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
class splunk::config::firewall() {
	
	class indexer() {
		@firewall { "200 $name TCP Incoming":
			proto => 'tcp',
			sport => $localreceiveport,
			chain => 'INPUT',
			action => 'accept',
			state   => ['NEW', 'RELATED', 'ESTABLISHED'],
		}		
	}
	class forwarder() {
		@firewall { "200 $name TCP Outgoing Dest":
			proto => 'tcp',
			dport => $indexerport,
			chain => 'OUTPUT',
			action => 'accept',
			state   => ['NEW', 'RELATED', 'ESTABLISHED'],
		}
		@firewall { "200 $name TCP Incoming Source":
			proto => 'tcp',
			sport => $indexerport,
			chain => 'INPUT',
			action => 'accept',
			state   => ['NEW', 'RELATED', 'ESTABLISHED'],
		}
		
		@firewall { "200 $name TCP Outgoing Source":
			proto => 'tcp',
			sport => $indexerport,
			chain => 'OUTPUT',
			action => 'accept',
			state   => ['NEW', 'RELATED', 'ESTABLISHED'],
		}
		@firewall { "200 $name TCP Incoming Dest":
			proto => 'tcp',
			dport => $indexerport,
			chain => 'INPUT',
			action => 'accept',
			state   => ['NEW', 'RELATED', 'ESTABLISHED'],
		}
		
		#
		# Syslog
		#
		@firewall { "200 $name UDP Syslog Outgoing Source":
			proto => 'udp',
			sport => '514',
			chain => 'OUTPUT',
			action => 'accept',
			state   => ['NEW', 'RELATED', 'ESTABLISHED'],
		}
		@firewall { "200 $name UDP Syslog Incoming Dest":
			proto => 'udp',
			dport => '514',
			chain => 'INPUT',
			action => 'accept',
			state   => ['NEW', 'RELATED', 'ESTABLISHED'],
		}
		
		
		
	}
	class client() {
		@firewall { "200 $name TCP Outgoing":
			proto => 'tcp',
			dport => $indexerport,
			chain => 'OUTPUT',
			action => 'accept',
			state   => ['NEW', 'RELATED', 'ESTABLISHED'],
		}
		@firewall { "200 $name TCP Incoming":
			proto => 'tcp',
			sport => $indexerport,
			chain => 'INPUT',
			action => 'accept',
			state   => ['NEW', 'RELATED', 'ESTABLISHED'],
		}
	}
	
}