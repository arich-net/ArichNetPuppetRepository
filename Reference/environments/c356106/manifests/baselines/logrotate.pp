# Class: c356106::logrotate
#
# Maintains logrotation accross our environment
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
#	include c356106::logrotate
#	include c356106::logrotate::pci
#
class c356106::logrotate() {
 
	# Gloabl log rotate config 
 	
	# Any specific PCI log rotation
	class pci() {

		logrotate::file { 'pci_cis_log':
			log        => [ '/var/log/pci_cis.log' ],
			options    => [ 'weekly', 'compress', 'rotate 10', 'missingok' ]
  		}	
	
		logrotate::file { 'clamscan.log':
			log        => [ '/var/log/clamav/clamscan.log' ],
			options    => [ 'weekly', 'compress', 'rotate 12', 'missingok', 'create 640  clamav adm' ]
 		}		
	}	
	
}