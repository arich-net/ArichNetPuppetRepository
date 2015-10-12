# Class: foreman::service
#
# Manages the foreman service
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
class foreman::service() {
	service {"foreman":
    	ensure => $foreman::params::passenger ? {
      				true => "stopped",
      				false => "running"
    	},
    	enable => $foreman::params::passenger ? {
      				true => "false",
      				false => "true",
    	},
    	hasstatus => true,
  	}
}