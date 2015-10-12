# Class: c356106::nttescripts
#
# Maintains the deployment of our NTTE scripts within our c356106 environment.
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
#	include c356106::nttescripts
#	include c356106::nttescripts::pci
#
class c356106::nttescripts() {
	
	##############
	# Cron entries
	#
	#cron { "example.sh":rme
	#	ensure  => present,
	#	command => "",
	#	user => root,
	#	hour => 0,
	#	minute => 0,
	#}
	cron { "autoremove_disabledprofiles.sh":
		ensure  => present,
		command => "/bin/sh /usr/local/ntte/scripts/autoremove_disabledprofiles.sh >> /var/log/autoremove.log",
		user => root,
		hour => 0,
		minute => 0,
		monthday => 1,
	}
	
	cron { "autoremove_oldprofiles.sh":
		ensure  => present,
		command => "/bin/sh /usr/local/ntte/scripts/autoremove_oldprofiles.sh > /var/log/autoremovecleaner.log",
		user => root,
		hour => 0,
		minute => 0,
		monthday => 1,
	}

	cron { "autoquota_profiles.sh":
		ensure  => present,
		command => "/bin/sh /usr/local/ntte/scripts/autoquota_profiles.sh > /var/log/autoquota.log",
		user => root,
		hour => 0,
		minute => 0,
		monthday => 1,
	}

	# We shouldn't need to but any configuration specific for PCI nodes
	class pci() {
	
		cron { "Check_CIS.pm":
			ensure  => present,
			command => "/usr/bin/perl /usr/local/ntte/c356106/scripts/pci_scripts/Check_CIS.pm check /etc/NTT/cis_templates/pci_logger.cfg /etc/NTT/cis_templates/pci_config.cfg",
			user => root,
			hour => 0,
			minute => 0,
			weekday => 7, 
		}
		
		case $::operatingsystem {
			/Ubuntu|Debian/: {
				cron { "Software_Inventory":
					ensure  => present,
					command => "/usr/local/ntte/c356106/scripts/pci_scripts/ubuntu_list_packages.sh",
					user => root,
					hour => 1,
					minute => 0,
					weekday => 7, 
				}				
			}
			/Redhat|Fedora/: {
				cron { "Software_Inventory":
					ensure  => present,
					command => "/usr/local/ntte/c356106/scripts/pci_scripts/redhat_list_packages.sh",
					user => root,
					hour => 1,
					minute => 0,
					weekday => 7, 
				}				
			}
		}
	
	}	
	
}
