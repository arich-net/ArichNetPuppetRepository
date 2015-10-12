# Class: apt::repo::puppetlabs
#
# This class defines the apt sources/keys & preferences for the puppet repo
#
# Parameters:
#
# Actions:
#	1) facter $operatingsystem convert to lowercase
#
# Requires:
#
# Sample Usage:
#
# [Remember: No empty lines between comments and class definition]
class puppet::repo::puppetlabs(){

# Just to ensure of any http errors accessing wrong page due to case issues
$lcase_os = inline_template("<%= operatingsystem.downcase -%>")

	case $::operatingsystem {
    	#/(?i)(Ubuntu|Debian)/: {
    	/(?i)(Debian|Ubuntu)/: {
      		case $::lsbdistcodename {
            	/(?i)(hardy|lucid|precise|squeeze|lenny|wheezy)/: {
            		
            		apt::source { 'puppetlabs':
						ensure => 'present',
						type => 'deb',
						# Repo structure has changed'
						#uri => "http://apt.puppetlabs.com/${lcase_os}",
						uri => "http://apt.puppetlabs.com/",
						dist => "${::lsbdistcodename}",
						components => ['main'],
					}
					apt::key { '4BD6EC30':
						ensure => 'present',
					}
					#apt::preferences { 'puppet': ensure => 'present', pin => 'oneiric', priority => '150',}
					          			
          		}
        	}
        }
        /(?i)(Redhat|centos)/: {
			yum::managed_yumrepo { puppetlabs:
				descr => 'Puppet Labs Packages',
				baseurl => 'http://yum.puppetlabs.com/el/$releasever/products/$basearch',
				enabled => 1,
				gpgcheck => 1,
				failovermethod => 'priority',
				gpgkey => 'http://yum.puppetlabs.com/RPM-GPG-KEY-puppetlabs',
				priority => 15,
			}
			yum::managed_yumrepo { puppetlabs_dependencies:
        		descr => 'Puppet Labs Packages',
        		baseurl => 'http://yum.puppetlabs.com/el/$releasever/dependencies/$basearch',
       			enabled => 1,
        		gpgcheck => 1,
        		failovermethod => 'priority',
        		gpgkey => 'http://yum.puppetlabs.com/RPM-GPG-KEY-puppetlabs',
        		priority => 15,
    		}
        }
        default: {
          	#fail 'Puppetlabs main repository only available for Ubuntu & Debian'
          	notify{"Module $module_name class $name is not supported on os: $::operatingsystem, arch: $::architecture": }
        }
      }
}
