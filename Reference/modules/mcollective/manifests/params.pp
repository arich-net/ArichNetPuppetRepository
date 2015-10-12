# Class: mcollective::params
#
# This module manages ldap
#
# Note1
# 	We cannot use architecture here due to a bug in the windows 1.6.10 facter not reporting 
#	correctly when using a 32bit OS on a 64bit Processor.
#	This will change when the hardwaremodel fact is changed to use the 'AddressWidth' from WMI,
#	as this seems more reliable when using virtual machines rather then the existin WMI query...
#	'select Architecture, Level from Win32_Processor'
#	More info :: http://projects.puppetlabs.com/issues/16948
#    	
# Facter 1.6.10 bug for x64 as per : http://projects.puppetlabs.com/issues/10261
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
class mcollective::params {
	
	$stomphost = ''
	$stompport = '6163'
	$stompuser = 'mcollective'
	$stomppasswd = 'marionette'
	
	case $::datacenter {
		'Slough': 		{ $sub_collective = 'londen01_collective' }
		'London': 		{ $sub_collective = 'londen02_collective' }
		'Frankfurt': 	{ $sub_collective = 'frnkge05_collective' }	
		'Paris 2': 		{ $sub_collective = 'parsfr02_collective' }				
		'Paris 3': 		{ $sub_collective = 'parsfr03_collective' }
		'Madrid': 		{ $sub_collective = 'mdrdsp04_collective' }				
		'San Jose': 	{ $sub_collective = 'snjsca04_collective' }				
		default: 		{ $sub_collective = 'default_collective' }
    }
    
  		
	case $::operatingsystem {
        windows: {
        	$owner = undef
        	$group = undef
        	$mode = undef
        	
       		$identity = $identity ? {
				'' => "${::hostname}.eu.verio.net",
				default => $identity,
		    }
		            	
        }
        default: {
        	$owner = root
        	$group = root
        	$mode = 0644
        	
       		$identity = $identity ? {
				'' => "$::fqdn",
				default => $identity,
		    }
    
        }
	}
	
	case $::operatingsystem {
    'centos': {
           case $::lsbdistrelease {
             /7./: {
                $pkg_version = '2.2.4-1.el7'
                $base_dir = '/etc/mcollective'
                $lib_dir = '/usr/libexec/mcollective'
                $facter_facts_path = '/etc/mcollective/facter_facts.yaml'
                $scope_facts_path = '/etc/mcollective/scope_facts.yaml'
                $yaml_facts = "${facter_facts_path}:${scope_facts_path}"
                $server_cfg_path = '/etc/mcollective/server.cfg'
                $logfile = '/var/log/mcollective.log'
             }
             /6./: {
                $pkg_version = '2.2.4-1.el6'
                $base_dir = '/etc/mcollective'
                $lib_dir = '/usr/libexec/mcollective'
                $facter_facts_path = '/etc/mcollective/facter_facts.yaml'
                $scope_facts_path = '/etc/mcollective/scope_facts.yaml'
                $yaml_facts = "${facter_facts_path}:${scope_facts_path}"
                $server_cfg_path = '/etc/mcollective/server.cfg'
                $logfile = '/var/log/mcollective.log'
             }
           } 
          }
    'redhat': {
                case $::lsbdistrelease {
                        /7./:{
                                $pkg_version = '2.2.4-1.el7'
                                $base_dir = '/etc/mcollective'
                                $lib_dir = '/usr/libexec/mcollective'
                                $facter_facts_path = '/etc/mcollective/facter_facts.yaml'
                                $scope_facts_path = '/etc/mcollective/scope_facts.yaml'
                                $yaml_facts = "${facter_facts_path}:${scope_facts_path}"
                                $server_cfg_path = '/etc/mcollective/server.cfg'
                                $logfile = '/var/log/mcollective.log'
                        }
                        /6./:{
                                $pkg_version = '2.2.4-1.el6'
                                $base_dir = '/etc/mcollective'
                                $lib_dir = '/usr/libexec/mcollective'
                                $facter_facts_path = '/etc/mcollective/facter_facts.yaml'
                                $scope_facts_path = '/etc/mcollective/scope_facts.yaml'
                                $yaml_facts = "${facter_facts_path}:${scope_facts_path}"
                                $server_cfg_path = '/etc/mcollective/server.cfg'
                                $logfile = '/var/log/mcollective.log'
                        }
                        /5./:{
                                $pkg_version = '2.2.4-1.el5'
                                $base_dir = '/etc/mcollective'
                                $lib_dir = '/usr/libexec/mcollective'
                                $facter_facts_path = '/etc/mcollective/facter_facts.yaml'
                                $scope_facts_path = '/etc/mcollective/scope_facts.yaml'
                                $yaml_facts = "${facter_facts_path}:${scope_facts_path}"
                                $server_cfg_path = '/etc/mcollective/server.cfg'
                                $logfile = '/var/log/mcollective.log'
                        }
                }
    }
    'Ubuntu': {
    	case $::lsbdistrelease {
			'8.04':{
				$pkg_version = '2.2.4-1'
				$base_dir = '/etc/mcollective'
				$lib_dir = '/usr/share/mcollective/plugins'
				$facter_facts_path = '/etc/mcollective/facter_facts.yaml'
				$scope_facts_path = '/etc/mcollective/scope_facts.yaml'
				$yaml_facts = "${facter_facts_path}:${scope_facts_path}"
				$server_cfg_path = '/etc/mcollective/server.cfg'
				$logfile = '/var/log/mcollective.log'
			}
			'10.04':{
				$pkg_version = '2.2.4-1'
				$base_dir = '/etc/mcollective'
				$lib_dir = '/usr/share/mcollective/plugins'
				$facter_facts_path = '/etc/mcollective/facter_facts.yaml'
				$scope_facts_path = '/etc/mcollective/scope_facts.yaml'
				$yaml_facts = "${facter_facts_path}:${scope_facts_path}"
				$server_cfg_path = '/etc/mcollective/server.cfg'
				$logfile = '/var/log/mcollective.log'
			}
			'12.04':{
				$pkg_version = '2.2.4-1'
				$base_dir = '/etc/mcollective'
				$lib_dir = '/usr/share/mcollective/plugins'
				$facter_facts_path = '/etc/mcollective/facter_facts.yaml'
				$scope_facts_path = '/etc/mcollective/scope_facts.yaml'
				$yaml_facts = "${facter_facts_path}:${scope_facts_path}"
				$server_cfg_path = '/etc/mcollective/server.cfg'
				$logfile = '/var/log/mcollective.log'
			}
      			'14.04':{
        			$pkg_version = '2.2.4-1'
        			$base_dir = '/etc/mcollective'
        			$lib_dir = '/usr/share/mcollective/plugins'
        			$facter_facts_path = '/etc/mcollective/facter_facts.yaml'
        			$scope_facts_path = '/etc/mcollective/scope_facts.yaml'
        			$yaml_facts = "${facter_facts_path}:${scope_facts_path}"
        			$server_cfg_path = '/etc/mcollective/server.cfg'
        			$logfile = '/var/log/mcollective.log'
      			}			 	
		}
    }
    'Debian': {
    	case $::lsbdistcodename {
			'wheezy':{
				$pkg_version = '2.2.4-1'
				$base_dir = '/etc/mcollective'
				$lib_dir = '/usr/share/mcollective/plugins'
				$facter_facts_path = '/etc/mcollective/facter_facts.yaml'
				$scope_facts_path = '/etc/mcollective/scope_facts.yaml'
				$yaml_facts = "${facter_facts_path}:${scope_facts_path}"
				$server_cfg_path = '/etc/mcollective/server.cfg'
				$logfile = '/var/log/mcollective.log'
			}
			'squeeze':{
				$pkg_version = '2.2.4-1'
				$base_dir = '/etc/mcollective'
				$lib_dir = '/usr/share/mcollective/plugins'
				$facter_facts_path = '/etc/mcollective/facter_facts.yaml'
				$scope_facts_path = '/etc/mcollective/scope_facts.yaml'
				$yaml_facts = "${facter_facts_path}:${scope_facts_path}"
				$server_cfg_path = '/etc/mcollective/server.cfg'
				$logfile = '/var/log/mcollective.log'
			}
			'sid':{
				$pkg_version = '2.2.4-1'
				$base_dir = '/etc/mcollective'
				$lib_dir = '/usr/share/mcollective/plugins'
				$facter_facts_path = '/etc/mcollective/facter_facts.yaml'
				$scope_facts_path = '/etc/mcollective/scope_facts.yaml'
				$yaml_facts = "${facter_facts_path}:${scope_facts_path}"
				$server_cfg_path = '/etc/mcollective/server.cfg'
				$logfile = '/var/log/mcollective.log'
			}
			'lenny':{
				$pkg_version = '2.2.4-1'
				$base_dir = '/etc/mcollective'
				$lib_dir = '/usr/share/mcollective/plugins'
				$facter_facts_path = '/etc/mcollective/facter_facts.yaml'
				$scope_facts_path = '/etc/mcollective/scope_facts.yaml'
				$yaml_facts = "${facter_facts_path}:${scope_facts_path}"
				$server_cfg_path = '/etc/mcollective/server.cfg'
				$logfile = '/var/log/mcollective.log'
			}		
		}
    }
    'solaris': { # Need to check this with facter on a sol box
    	case $::lsbdistrelease {
    		'i386':{
    			$pkg_version = ''
    			$base_dir = '/etc/mcollective'
    			$lib_dir = ''
    			$facter_facts_path = '/etc/mcollective/facter_facts.yaml'
    			$scope_facts_path = '/etc/mcollective/scope_facts.yaml'
    			$yaml_facts = "${facter_facts_path}:${scope_facts_path}"
    			$server_cfg_path = '/etc/mcollective/server.cfg'
    			$logfile = '/var/log/mcollective.log'
    		}
    		'x86_64':{
    			$pkg_version = ''
    			$base_dir = '/etc/mcollective'
    			$lib_dir = ''
    			$facter_facts_path = '/etc/mcollective/facter_facts.yaml'
    			$scope_facts_path = '/etc/mcollective/scope_facts.yaml'
    			$yaml_facts = "${facter_facts_path}:${scope_facts_path}"
    			$server_cfg_path = '/etc/mcollective/server.cfg'
    			$logfile = '/var/log/mcollective.log'
    		}
    	}
    }
    'windows': {
		# Note 1
    	#case $::architecture {
    	case $::env_windows_installdir {
    		/(?i)(x86)/:{
    			$pkg_version = ''
    			$base_dir = 'c:/Program Files (x86)/MCollective/etc'
    			$lib_dir = 'c:/Program Files (x86)/MCollective/plugins'
    			$facter_facts_path = 'c:/Program Files (x86)/MCollective/etc/facter_facts.yaml'
    			$scope_facts_path = 'c:/Program Files (x86)/MCollective/etc/scope_facts.yaml'
    			$yaml_facts = "${facter_facts_path};${scope_facts_path}"
    			$server_cfg_path = 'c:/Program Files (x86)/MCollective/etc/server.cfg'
    			$logfile = 'c:/Program Files (x86)/MCollective/mcollective.log'    			
    		}
    		default:{
    			$pkg_version = ''
    			$base_dir = 'c:/Program Files/MCollective/etc'
    			$lib_dir = 'c:/Program Files/MCollective/plugins'    			
    			$facter_facts_path = 'c:/Program Files/MCollective/etc/facter_facts.yaml'
    			$scope_facts_path = 'c:/Program Files/MCollective/etc/scope_facts.yaml'
    			$yaml_facts = "${facter_facts_path};${scope_facts_path}"
    			$server_cfg_path = 'c:/Program Files/MCollective/etc/server.cfg'
    			$logfile = 'c:/Program Files/MCollective/mcollective.log'
    		}
    	}
    }
    default: {
    	# Fail the catalog compliation becasue we're mean!
		fail("Module $::module_name class $name is not supported on os: $::operatingsystem, arch: $::lsbdistrelease")
    }
  } # end case $operatingsystem
	
		
}
