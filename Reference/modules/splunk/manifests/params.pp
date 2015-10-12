# Class: splunk::params
#
# This class manages Splunk parameters
#
# Operating systems:
#	:Working
#		Ubuntu 10.04
#		RHEL5
# 	:Testing
#
# Parameters:
# - The $splunk_indexer_pkg used
# - The $splunk_forwarder_pkg used 
#
# Actions:
#	1) check facter architecture variable on solaris 32bit and 64bit
#
# Requires:
#	Packages are stored on puppeteer (evl3300442) : /etc/puppet-extpackages/splunk/
#	"/etc/puppet_tmp-files/" = Puppet client module	
#	
# Sample Usage:
#
class splunk::params {

  # Splunks default admin password is changeme and we use this for initial config
  # then we need to change it
  $splunk_global_admin_user = 'admin'
  $splunk_global_admin_passwd = 'adminpassword'
  
  $splunk_file_path_local = '/etc/puppet-tmpfiles/'
  $splunk_file_path_remote = 'puppet:///ext-packages/splunk/'
  
  $splunk_indexer_path = '/opt/splunk'
  $splunk_forwarder_path = '/opt/splunk'
  $splunk_client_path = '/opt/splunkforwarder'
  
  case $operatingsystem {
    'centos', 'redhat', 'fedora': {
		case $architecture {
			'i386':{
				$provider = 'rpm'
				$splunk_indexer_pkg = 'splunk-5.0.9-213964.i386.rpm'
				$splunk_forwarder_pkg = 'splunk-5.0.9-213964.i386.rpm'
				$splunk_client_pkg = 'splunkforwarder-5.0.9-213964.i386.rpm'
			}
			'x86_64', 'amd64', 'i686':{
				$provider = 'rpm'
				$splunk_indexer_pkg = 'splunk-5.0.9-213964-linux-2.6-x86_64.rpm'
				$splunk_forwarder_pkg = 'splunk-5.0.9-213964-linux-2.6-x86_64.rpm'
				$splunk_client_pkg = 'splunkforwarder-5.0.9-213964-linux-2.6-x86_64.rpm'
			}	
		 }
    }
    'Ubuntu', 'debian': {
    	case $architecture {
			'i386':{
				$provider = 'dpkg'
				$splunk_indexer_pkg = 'splunk-5.0.9-213964-linux-2.6-intel.deb'
				$splunk_forwarder_pkg = 'splunk-5.0.9-213964-linux-2.6-intel.deb'
				$splunk_client_pkg = 'splunkforwarder-5.0.9-213964-linux-2.6-intel.deb'
			}
			'x86_64', 'amd64', 'i686':{
				$provider = 'dpkg'
				$splunk_indexer_pkg = 'splunk-5.0.9-213964-linux-2.6-amd64.deb'
				$splunk_forwarder_pkg = 'splunk-5.0.9-213964-linux-2.6-amd64.deb'
				$splunk_client_pkg = 'splunkforwarder-5.0.9-213964-linux-2.6-amd64.deb'
			}	
		 } 
    }
    'solaris': { # Need to check this with facter on a sol box
    	case $architecture {
    		'i386':{
    			$splunk_indexer_pkg = ''
    			$splunk_forwarder_pkg = ''
    			$splunk_client_pkg = 'splunkforwarder-4.2.3-105575-solaris-9-intel.pkg.Z'
    		}
    		'x86_64':{
    			$splunk_indexer_pkg = ''
    			$splunk_forwarder_pkg = ''
    			$splunk_client_pkg = 'splunkforwarder-4.2.3-105575-solaris-10-intel.pkg.Z'
    		}
    	}
    }
    default: {
    	# Fail the catalog compliation becasue we're mean!
		fail("Module $module_name is not supported on os: $operatingsystem, arch: $architecture")
    }
  } # end case $operatingsystem
} # End splunk::params
