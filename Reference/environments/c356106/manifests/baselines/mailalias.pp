# Class: c356106::mailalias
#
# Maintains /etc/aliases
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
#	include c356106::mailalias
#
class c356106::mailalias() {
	
	# Add /etc/aliases entries for env:c356106 here.
	mailalias { 'filers-spain' :
		ensure => present,
		recipient => ['imanol.lazcano@ntt.eu', 
					  'ivan.fontan@ntt.eu',
					  'ruben.fernandez@ntt.eu',
					  'alessandro.meloni@ntt.eu',
					  'jaume.alemany@ntt.eu',
		]
	}
	
	class pci() {
		mailalias { 'pci_administrators' :
			ensure => present,
			recipient => ['ariel.vasquez@ntt.eu'				
			]			
		}
		
		mailalias { 'root' :
			ensure => present,
			recipient => [ 'pci_administrators'				
			]
		}
		
		mailalias { 'postmaster' :
			ensure => present,
			recipient => [ 'pci_administrators'				
			]
		}
	}
	
}