# Class: <class_name>
#
# Description of module
#
# Operating systems:
#	:Working
#
# 	:Testing
#
# Parameters:
#	List of all parameters used in this class
#
# Actions:
#	List of any outstanding actions or notes for changes to be made.
#
# Requires:
#	Class requirements
#
# Sample Usage:
#	include <class_name>
#
class nagios() { 
    package { "$nagios::params::package_name":
           ensure                => latest,
           description           => "nagios server package",
    }
    service { "${nagios::params::service_name}":
           ensure                => running,
           enable                => true,
           hasrestart            => true,
           require               => Package["$nagios::params::package_name"],
    }	
}
