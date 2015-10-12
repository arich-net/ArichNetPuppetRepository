# Class: puppet::repo::skettlerppa
#
# This class defines the apt sources/keys & preferences for the Skettler PPA repo
# we can remove the use of this PPA after legacy debian systems are updated
# This is due to puppet => 2.0 not in the repositories.
#
# This is only used on Debian+Lenny and because the puppetlabs repo is also there we pin the packages.
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
class puppet::repo::skettlerppa(){

	case $::operatingsystem {
    	/(?i)(Debian)/: {
      		case $::lsbdistcodename {
            	/(?i)(lenny)/: {
            		
            		apt::source { 'skettlerppa':
						ensure => 'present',
						type => 'deb',
						uri => "http://ppa.launchpad.net/skettler/puppet/ubuntu",
						dist => "lucid",
						components => ['main'],
					}
					apt::key { 'C18789EA':
						ensure => 'present',
					}
					apt::preferences { 'puppet': ensure => 'present', pin => 'version', pin_value => '2.7.6~lucid~ppa1', priority => '900',}
					apt::preferences { 'puppet-common': ensure => 'present', pin => 'version', pin_value => '2.7.6~lucid~ppa1', priority => '900',}
					#apt::preferences { 'facter': ensure => 'present', pin => 'version', pin_value => '1.6.0~lucid~ppa1', priority => '900',}
					apt::preferences { 'libaugeas-ruby': ensure => 'present', pin => 'version', pin_value => '0.4.1~lucid~ppa1', priority => '900',}
          		}
        	}
        }
        default: {
          	#fail 'SkettlerPPA main repository only available/used for Debian Lenny'
          	notify{"Module $module_name class $name is not supported on os: $::operatingsystem, arch: $::architecture": }
        }
      }
}
