# Class: apt::upgrade
#
# This class includes the apt-get upgrade command and can be called as part of run stages,
# or where required.
# Implemented primarially for the bootstrap env
#
# Parameters:
#
# Actions:
#
# Requires:
#
# Sample Usage:
#
#	class { 'apt::upgrade': stage =>'after'}
#
# [Remember: No empty lines between comments and class definition]
class apt::upgrade() {

	exec { "apt-get_upgrade":
		command => "apt-get upgrade -y",
	}

}
