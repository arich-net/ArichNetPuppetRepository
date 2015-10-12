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
class puppet::enc-wrapper::client {
	class { 'puppet::client': 
		puppet_master => $::puppet-client-puppet_master,
		puppet_environment => $::puppet-client-puppet_environment,
		puppet_certname => $::puppet-client-puppet_certname,
		puppet_report => $::puppet-client-puppet_report,
	}
}