# Class: puppet::client
#
# This module manages puppet client
#
# Parameters:
#	$puppet_master = puppet master server
#	$puppet_certname = "generally the node name" : defaults to fqdn as per facter variable. (Note 1)
#	$puppet_report = true/false : defaults to true.
#	$puppet_environment = node environment (cxxxxxx) as per nexus : defaults to production but wont do much..
#
# Notes
#  1) Windows build does not by default have dns suffix applied to the interface
#		nor can we ensure that the first interface as per wnic is the pip. Facter uses wmnic to get the fqdn.
#		example = wmic path win32_networkadapterconfiguration get ipaddress, dnsdomain, ipenabled
#
#	we proxy certificate/report reuqests via the local puppetmasters, so there is no need to specify
#	the puppeteer in the puppet node config. security aswell as avoiding fw rules.
#
# Actions:
#
# Requires:
#
# Sample Usage:
#
# [Remember: No empty lines between comments and class definition]
class puppet::params {

	case $::hostname {
		/^e{1}..33.{5}$/: {
			$server = $puppet_master ? {
				'' => "puppetmaster.londen01.infra.ntt.eu",
				default => $puppet_master,
    		}
    		$ca_server = "puppetmaster.londen01.infra.ntt.eu"
			$report_server = "puppetmaster.londen01.infra.ntt.eu"
		}
		/^e{1}..00.{5}$/: {
			$server = $puppet_master ? {
				'' => "puppetmaster.londen02.infra.ntt.eu",
				default => $puppet_master,
    		}
    		$ca_server = "puppetmaster.londen02.infra.ntt.eu"
			$report_server = "puppetmaster.londen02.infra.ntt.eu"
		}
		/^e{1}..03.{5}$/: {
			$server = $puppet_master ? {
				'' => "puppetmaster.frnkge05.infra.ntt.eu",
				default => $puppet_master,
    		}
    		$ca_server = "puppetmaster.frnkge05.infra.ntt.eu"
			$report_server = "puppetmaster.frnkge05.infra.ntt.eu"
		}
		/^e{1}..19.{5}$/: {
			$server = $puppet_master ? {
				'' => "puppetmaster.mdrdsp04.infra.ntt.eu",
				default => $puppet_master,
    		}
    		$ca_server = "puppetmaster.mdrdsp04.infra.ntt.eu"
			$report_server = "puppetmaster.mdrdsp04.infra.ntt.eu"
		}
		/^e{1}..20.{5}$/: {
			$server = $puppet_master ? {
				'' => "puppetmaster.parsfr03.infra.ntt.eu",
				default => $puppet_master,
    		}
    		$ca_server = "puppetmaster.parsfr03.infra.ntt.eu"
			$report_server = "puppetmaster.parsfr03.infra.ntt.eu"
		}
		default: { 
			$server = $puppet_master ? {
				'' => "puppeteer.londen01.infra.ntt.eu",
				default => $puppet_master,
    		}
    		$ca_server = "puppeteer.londen01.infra.ntt.eu"
			$report_server = "puppeteer.londen01.infra.ntt.eu"
		}
		#default: { notice("Unrecognized hostname from facter") }
    }

	# Windows domain fact does not report correctly.
	# Force lowercase on certname: http://projects.puppetlabs.com/issues/1168
	# some customers are changing the computername on windows and this causes
	# uppercase certnames to appear. Lets just force the hostname/fqdn to downcase just incase.
	$lcase_hostname = inline_template("<%= hostname.downcase -%>")
	case $::operatingsystem {
	    'windows': {	    	    	
	     # Certname, we default to FQDN, we used to use "${::hostname}.<gin-dc-name>.oob.infra.ntt.eu",
        $certname = $puppet_certname ? {
          '' => "${lcase_hostname}.eu.verio.net",
          default => $puppet_certname,
        }
    		
	    } #windows
	    default: {
	      $lcase_fqdn = inline_template("<%= fqdn.downcase -%>")
	    	
	    	# Certname, we default to FQDN, we used to use "${::hostname}.<gin-dc-name>.oob.infra.ntt.eu",
			$certname = $puppet_certname ? {
				'' => "$lcase_fqdn",
				default => $puppet_certname,
    		}    
	    }
	}
	
	###########
	# OS specific variables and defaults
	case $::operatingsystem {
		'ubuntu': {
			$puppet_pkgversion = "2.7.19-1puppetlabs2"
	    	$configfile = "/etc/puppet/puppet.conf"
	    	$tmpfiles_path = "/etc/puppet-tmpfiles/"			
		}
		'debian': {
			$puppet_pkgversion = "2.7.19-1puppetlabs2"
	    	$configfile = "/etc/puppet/puppet.conf"
	    	$tmpfiles_path = "/etc/puppet-tmpfiles/"			
		}
		'redhat': {
			case $::lsbdistrelease {
				/6./: {
					$puppet_pkgversion = "2.7.19-1.el6"
				}
				default: {
					$puppet_pkgversion = "2.7.19-1.el6"
				}
			}
	    	$configfile = "/etc/puppet/puppet.conf"
	    	$tmpfiles_path = "/etc/puppet-tmpfiles/"			
		}
	    'windows': {
	    	case $::kernelmajversion {
	    		'5.2':{ # Server 2003
	    			$configfile = 'C:/Documents and Settings/All Users/Application Data/PuppetLabs/puppet/etc/puppet.conf'
	    		}
	    		'6.0':{ # Server 2008
	    			$configfile = 'c:/ProgramData/PuppetLabs/puppet/etc/puppet.conf'
	    		}
	    		'6.1':{ # Server 2008 R2
	    			$configfile = 'c:/ProgramData/PuppetLabs/puppet/etc/puppet.conf'
	    		}
	    		'6.2':{ # Server 2012
	    			$configfile = 'c:/ProgramData/PuppetLabs/puppet/etc/puppet.conf'
	    		}
	    	}
	    	$tmpfiles_path = "c:\\puppet-tmpfiles\\"
	    	
    		
	    } #windows
	    'freebsd': {
	    	$configfile = "/usr/local/etc/puppet/puppet.conf"
	    	$tmpfiles_path = "/etc/puppet-tmpfiles/"
	    }  
	    default: {

	    }
	}
	##############

    
    # Puppet service
    # true/false 
    $run_as_daemon = $puppet_daemon ? {
        true => true,
        false => false,
        default => false,
    }
      
	# CA Server
	$is_ca_server = false

	# Reports
	$report = true
	
	# Environment
	$environment = production
	
	# The run interval
    $runinterval = 1800

	# Use passenger (Apache's mod_ruby) instead of default WebBrick ($puppet_passenger). Default: no
    $passenger = $puppet_passenger ? {
        true => true,
        false => false,
        default => false,
    }
    
    $passenger_app_root = '/var/lib/puppet/rack'

	# Use storeconfigs, needed for exported resources ($puppet_storeconfigs). Default: no
	$storeconfigs = false
    $storeconfigs_db = puppet
    $storeconfigs_dbuser = puppet
    $storeconfigs_dbpasswd = puppet
    

	# Define the inventory service server (Set "localhost" to use the local puppetmaster)
    $inventoryserver = $puppet_inventoryserver ? {
        '' => "",
        default => "$puppet_inventoryserver",
    }



	# Define Puppet version. Autocalculated: "0.2" for 0.24/0.25 "old" versions, 2.x for new 2.6.x branch.
    $version = $puppetversion ? {
        /(^0.)/ => "0.2",
        default => "2.x",
    }

	# Firewall
	$firewall = $puppet_firewall ? {
        true => true,
        false => false,
        default => true,
    }
	
	
    $packagename = $::operatingsystem ? {
        solaris => "CSWpuppet",
        default => "puppet",
    }

    $packagename_server = $::operatingsystem ? {
        debian => "puppetmaster",
        ubuntu => "puppetmaster",
        default => "puppet-server",
    }

    $servicename = $::operatingsystem ? {
        solaris => "puppetd",
        default => "puppet",
    }

    $servicename_server = $::operatingsystem ? {
        default => "puppetmaster",
    }

    $processname = $version ? {
        "0.2" => "puppetd",
        "2.x" => $::operatingsystem ? {
            redhat => "puppetd",
            centos => "puppetd",
            default => "puppet",
        },
    }

    $processname_server = $::operatingsystem ? {
        default => "puppetmasterd",
    }

    $hasstatus = $::operatingsystem ? {
        debian => false,
        ubuntu => false,
        default => true,
    }

    $hasstatus_server = $::operatingsystem ? {
        debian => false,
        ubuntu => false,
        default => true,
    }
    
   	$configfile_mode = $::operatingsystem ? {
        default => "644",
    }

    $configfile_owner = $::operatingsystem ? {
        default => "root",
    }

    $configfile_group = $::operatingsystem ? {
        default => "root",
    }

    $configdir = $::operatingsystem ? {
        freebsd => "/usr/local/etc/puppet/",
        default => "/etc/puppet",
    }

    $basedir = $::operatingsystem ? {
        redhat => "/usr/lib/ruby/site_ruby/1.8/puppet",
        centos => "/usr/lib/ruby/site_ruby/1.8/puppet",
        default => "/usr/lib/ruby/1.8/puppet",
    }

    $pidfile = $::operatingsystem ? {
        default => "/var/run/puppet/agent.pid",
    }

    $pidfile_server = $::operatingsystem ? {
        default => "/var/run/puppet/master.pid",
    }
    
    $logdir = $::operatingsystem ? {
        debian => "/var/log/syslog",
        ubuntu => "/var/log/syslog",
        default => "/var/log/messages",
    }


}

