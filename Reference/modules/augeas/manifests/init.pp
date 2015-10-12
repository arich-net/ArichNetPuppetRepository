# Class: augeas
#
# This class maintains augeas packages, libs and lenses
#
# Operating systems:
#	:Working
#		Ubuntu 10.04
#		RHEL5
#		RHEL6
# 	:Testing
#
# Parameters:
#	#Lenses
#		Lenses are stored in puppet:///modules/augeas/lenses, these all will be copied to 
#		/usr/share/augeas/lenses/contrib for usage in puppet runs to parse config files.
#
# Actions:
#
# Sample Usage:
#	*IMPORTANT* please do not include directly in node manifests!
#	This class is included inside puppet::client due to the requirement of the puppetlabs repo's
#
class augeas {
  
  include augeas::params
  
	case $::operatingsystem {
    	/RedHat|CentOS|Fedora/: { include augeas::redhat }
    	/Debian|Ubuntu/: { include augeas::debian }
    	default: { notify{"Module $module_name is not supported on os: $::operatingsystem, arch: $::architecture": } }
  	}

	class base {

		file { "/usr/share/augeas/lenses/contrib":
    		ensure => directory,
    		recurse => true,
    		purge => true,
    		force => true,
    		mode => 0644,
    		owner => "root",
    		group => "root",
    		source  => "puppet:///modules/augeas/lenses",
  		}
	}

	class redhat inherits base {
		
		case $::lsbmajdistrelease {
			'5': {
					# May no longer be required?
  					package { "augeas":
      					ensure => present,
      					before => File["/usr/share/augeas/lenses/contrib"],
						require => [Class["yum"], Exec['yum_update']],
  					}				
			}
		}
		
  		package { "augeas-libs":
      		ensure => present,
      		before => File["/usr/share/augeas/lenses/contrib"],
			require => [Class["yum"], Exec['yum_update']],
  		}
  		package { "ruby-augeas": 
  			ensure => present,
  			require => [Class["yum"], Exec['yum_update']],
		}

	}
	
	class debian inherits base {
      case $::lsbdistcodename {
        /lucid/: {
          file { "$augeas::params::augeas_file_path_local$augeas::params::augeas_package_libaugeas_package":
            owner   => root,
            group   => root,
            mode    => 644,
            ensure  => present,
            source  => "${augeas::params::augeas_file_path_remote}${augeas::params::augeas_package_libaugeas_package}", 
          }          
          file { "$augeas::params::augeas_file_path_local$augeas::params::augeas_package_libaugeas18_package":
            owner   => root,
            group   => root,
            mode    => 644,
            ensure  => present,
            source  => "${augeas::params::augeas_file_path_remote}${augeas::params::augeas_package_libaugeas18_package}", 
          }                    
          package { "$augeas::params::augeas_package_libaugeas_name":     
            ensure => latest,
            provider => "dpkg",
            source => "${augeas::params::augeas_file_path_local}${augeas::params::augeas_package_libaugeas_package}",
            # require => File["$splunk::params::splunk_file_path_local$splunk::params::splunk_client_pkg"],        
          }          
          package { "$augeas::params::augeas_package_libaugeas18_name":     
            ensure => latest,
            provider => "dpkg",
            source => "${augeas::params::augeas_file_path_local}${augeas::params::augeas_package_libaugeas18_package}",
            # require => File["$splunk::params::splunk_file_path_local$splunk::params::splunk_client_pkg"],        
          }          
        }
        default: {                  
		  		package { ["augeas-lenses", "libaugeas0", "augeas-tools"]:
		       		ensure => present,
		       		before => File["/usr/share/augeas/lenses/contrib"],
		       		require => [Class["apt"], Exec['apt-get_update']],
		       		
		  		}
		  		package { "libaugeas-ruby1.8": 
		  			ensure => present,
		  			require => [Class["apt"], Exec['apt-get_update']],
		  		}
        } 	    
	   }	   
	 }	
}