# Class: hiera::params
#
# Manages params for hiera
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
class hiera::params {
    
	case $::operatingsystem {
	    'redhat': {
	    }
	    'Ubuntu': {
			$backend_dir = "/usr/lib/ruby/vendor_ruby/hiera/backend"
	    }
	    'windows': {
	    }
	    default: {
			fail("Module $::module_name class $name is not supported on os: $::operatingsystem, arch: $::lsbdistrelease")
	    }
	}
	
		
}