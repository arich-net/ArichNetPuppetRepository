# Class: squid::config::firewall
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
class squid::config::firewall() {
	
		@firewall { '200 Squid TCP Incoming':
			proto => 'tcp',
			dport => $squid_port,
			chain => 'INPUT',
			action => 'accept',
			state   => ['NEW', 'RELATED', 'ESTABLISHED'],
		}
		
		@firewall { '200 Squid TCP Outgoing':
			proto => 'tcp',
			sport => $squid_port,
			chain => 'OUTPUT',
			action => 'accept',
			state   => ['RELATED', 'ESTABLISHED'],
		}
		
		@firewall { '200 Squid HTTP Outgoing':
			proto => 'tcp',
			dport => '80',
			chain => 'OUTPUT',
			action => 'accept',
			state   => ['NEW', 'RELATED', 'ESTABLISHED'],
		}
		
		@firewall { '200 Squid HTTP Incoming':
			proto => 'tcp',
			sport => '80',
			chain => 'INPUT',
			action => 'accept',
			state   => ['RELATED', 'ESTABLISHED'],
		}
		
		@firewall { '200 Squid HTTPS Outgoing':
			proto => 'tcp',
			dport => '443',
			chain => 'OUTPUT',
			action => 'accept',
			state   => ['NEW', 'RELATED', 'ESTABLISHED'],
		}
		
		@firewall { '200 Squid HTTPS Incoming':
			proto => 'tcp',
			sport => '443',
			chain => 'INPUT',
			action => 'accept',
			state   => ['RELATED', 'ESTABLISHED'],
		}
		
		@firewall { '200 Squid FTP Outgoing':
			proto => 'tcp',
			dport => '21',
			chain => 'OUTPUT',
			action => 'accept',
			state   => ['NEW', 'RELATED', 'ESTABLISHED'],
		}
		
		@firewall { '200 Squid FTP Incoming':
			proto => 'tcp',
			sport => '21',
			chain => 'INPUT',
			action => 'accept',
			state   => ['RELATED', 'ESTABLISHED'],
		}
		
		@firewall { '200 Squid FTP-Data Outgoing':
			proto => 'tcp',
			dport => '20',
			chain => 'OUTPUT',
			action => 'accept',
			state   => ['NEW', 'RELATED', 'ESTABLISHED'],
		}
		
		@firewall { '200 Squid FTP-Data Incoming':
			proto => 'tcp',
			sport => '20',
			chain => 'INPUT',
			action => 'accept',
			state   => ['RELATED', 'ESTABLISHED'],
		}
				
}