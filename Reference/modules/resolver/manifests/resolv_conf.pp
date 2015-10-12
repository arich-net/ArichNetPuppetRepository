# define: resolver::resolv_conf
#
#	Manages /etc/resolv.conf
#
# Operating systems:
#	:Working
#		Ubuntu 10.04
#		RHEL5
# 	:Testing
#
# Parameters:
#
# Actions:
#
# Requires:
#
# Sample Usage:
#	resolv_conf { "example":
#		domainname  => "mydomain",
#		searchpath  => ['mydomain', 'test.mydomain'],
#		nameservers => ['192.168.1.100', '192.168.1.101', '192.168.1.102'],
#	}
#
define resolver::resolv_conf($domainname = "$domain", $searchpath, $nameservers) {
	file { "/etc/resolv.conf":
		owner   => root,
		group   => root,
		mode    => 644,
		content => template("resolver/resolv.conf.erb"),
	}
    
	    # We could modify this and create a resource per ip in $nameserver ?
		@firewall { '200 DNS Outgoing':
			proto => 'udp',
			dport => '53',
			chain => 'OUTPUT',
			action => 'accept',
		}
		@firewall { '200 DNS Incoming':
			proto => 'udp',
			sport => '53',
			chain => 'INPUT',
			action => 'accept',
		}
	
}