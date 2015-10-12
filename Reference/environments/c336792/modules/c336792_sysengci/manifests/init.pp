# Class: sysengci
#
# sysengci, used for internal continuous integration
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
class c336792_sysengci {

	file { "/usr/local/sysengci":
		ensure  => directory,
		owner => root,
    group => root,
		recurse => true,
		purge => true,
		force => true, # Forces a removal if ensure => absent
		backup => false,
		source => "puppet:///modules/c336792_sysengci/sysengci/"
	}
				     
}

