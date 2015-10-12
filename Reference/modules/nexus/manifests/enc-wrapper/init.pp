# class: <name>
#
# Parameters:
#	$puppet-client-puppet_environment = puppets environment
#
# Example:
# class puppet::enc-wrapper::client {
#  class { 'puppet::client':
#	puppet_environment => $::puppet-client-puppet_environment,
#	}
# }
#
# [Remember: No empty lines between comments and class definition]
class <module-name>::enc-wrapper::<class-name> {
	
}