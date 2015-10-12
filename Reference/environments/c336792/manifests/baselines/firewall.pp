# Class: c336792::firewall
#
# Maintains custom firewall rules for all hosts defined in environment c336792.
#
# Operating systems:
#	:Working
#
# 	:Testing
#
# Parameters:
#
# Actions:
#
# Sample Usage:
#	include c336792::firewall
#	include c336792::firewall::pci
#
class c336792::firewall() {
	
	# Check if you have defined the sys@firewall module for running catalog.
	# we wont fail but we will output a message.
	if ! defined( "sysfirewall" ) {
		notify{"Module $module_name is not supported as module: sysfirewall is not defined.": }
    } else {
    	
    	#
    	# Define rules here
    	#
    	
    }
    
	# Specific PCI class, contain all @firewall rules for specific PCI systems here.
	#
	class pci() {

		# PROXY rules
		@firewall { '300 Proxy TCP Outgoing':
			proto => 'tcp',
			dport => '3128',
			chain => 'OUTPUT',
			action => 'accept',
			state   => ['NEW', 'RELATED', 'ESTABLISHED'],
		}
		@firewall { '300 Proxy TCP Incoming':
			proto => 'tcp',
			sport => '3128',
			chain => 'INPUT',
			action => 'accept',
			state   => ['RELATED', 'ESTABLISHED'],
		}
		
		# LDAP and LDAPS rules
		@firewall { '300 LDAP TCP Outgoing':
			proto => 'tcp',
			dport => '389',
			chain => 'OUTPUT',
			action => 'accept',
			state   => ['NEW', 'RELATED', 'ESTABLISHED'],
		}
		@firewall { '300 LDAP TCP Incoming':
			proto => 'tcp',
			sport => '389',
			chain => 'INPUT',
			action => 'accept',
			state   => ['RELATED', 'ESTABLISHED'],
		}		
		@firewall { '300 LDAPS TCP Outgoing':
			proto => 'tcp',
			dport => '636',
			chain => 'OUTPUT',
			action => 'accept',
			state   => ['NEW', 'RELATED', 'ESTABLISHED'],
		}
		@firewall { '300 LDAPS TCP Incoming':
			proto => 'tcp',
			sport => '636',
			chain => 'INPUT',
			action => 'accept',
			state   => ['RELATED', 'ESTABLISHED'],
		}
		
		# DNS Rules
		@firewall { '300 DNS Outgoing':
			proto => 'udp',
			dport => '53',
			chain => 'OUTPUT',
			action => 'accept',
		}
		@firewall { '300 DNS Incoming':
			proto => 'udp',
			sport => '53',
			chain => 'INPUT',
			action => 'accept',
		}					
	
		# MAIL Rules	
		@firewall { '300 MAIL TCP Outgoing':
			proto => 'tcp',
			dport => '25',
			chain => 'OUTPUT',
			action => 'accept',
			state   => ['NEW', 'RELATED', 'ESTABLISHED'],
		}
		@firewall { '300 MAIL TCP Incoming':
			proto => 'tcp',
			sport => '25',
			chain => 'INPUT',
			action => 'accept',
			state   => ['RELATED', 'ESTABLISHED'],
		}	
		
		# Xceedium Rules
		@firewall { '300 Xceedium TCP Incoming':
			proto => 'tcp',
			dport => '8550',
			chain => 'INPUT',
			action => 'accept',
			state   => ['NEW', 'RELATED', 'ESTABLISHED'],
		}
		@firewall { '300 Xceedium TCP Outgoing':
			proto => 'tcp',
			sport => '8550',
			chain => 'OUTPUT',
			action => 'accept',
			state   => ['RELATED', 'ESTABLISHED'],
		}	
		@firewall { '300 Xceedium Alerts TCP Outgoing':
			proto => 'tcp',
			dport => '443',
			chain => 'OUTPUT',
			action => 'accept',
			state   => ['NEW', 'RELATED', 'ESTABLISHED'],
		}
		@firewall { '300 Xceedium Alerts TCP Incoming':
			proto => 'tcp',
			sport => '443',
			chain => 'INPUT',
			action => 'accept',
			state   => ['RELATED', 'ESTABLISHED'],
		}
		
		# ICMP Rules
		@firewall { '300 PCI ICMP Outgoing':
			proto => 'icmp',
			chain => 'OUTPUT',
			action => 'accept',			
		}
		@firewall { '300 PCI ICMP Incoming':
			proto => 'icmp',
			chain => 'INPUT',
			action => 'accept',			
		}		
	
	}
		
}