# Class: bootstrap::template
#
# Used..
#
# Parameters:
#
# Actions:
#
#	1) Create support to remove users
#		bootstrap::users::remove{ '':}
#		We can remove and re-add the users but for now we will just remove specifics
#	
# Requires:
#
# Sample Usage:
#
#	include bootstrap::template
#	class { 'bootstrap::template': }
#
# [Remember: No empty lines between comments and class definition]
class bootstrap::template() {

	exec {'clean_ssh_host_keys': command => "rm -rf /etc/ssh/ssh_host_*" }
	exec {'clean_root_home': command => "/home/root/.bash_history" }
	exec {'clean_root_mail': command => "/var/spool/mail/root" }
	exec {'clean_nttuser': command => "/home/nttuser/.bash_history" }				

} 
