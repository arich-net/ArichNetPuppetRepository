# Class: puppet::client
#
# This module manages puppet client
#
# Parameters:
#	$puppet_daemon = true/false : shall we daemonize the puppet client process? default:false
#	$puppet_master = puppet master server
#	$puppet_environment = node environment (cxxxxxx) as per nexus : defaults to production but wont do much..
#	$puppet_certname = "generally the node name" : defaults to fqdn as per facter variable.
#	$puppet_report = true/false : defaults to true.
#	$puppet_role = client/master/puppeteer : defaults to client
#
# Actions:
#	1) Convert to crontab run or use mcollective?
#	2) Needs tidying up, needs alot of values converted to variables inside params.pp
#	3) Cleaner windows package management..
#
# Requires:
#
# Sample Usage:
# class { 'puppet::client': 
#		puppet_master => 'puppeteer.londen01.oob.infra.ntt.eu',
#		puppet_environment => 'c336792',
#		puppet_certname => 'puppetmaster.londen01.oob.infra.ntt.eu',
#		puppet_report => false,
#		}
#
# [Remember: No empty lines between comments and class definition]
class puppet::client(	$puppet_daemon = $::puppet::params::run_as_daemon,
						$puppet_master= $::puppet::params::server, 
						$puppet_environment= $::puppet::params::environment, 
						$puppet_certname= $::puppet::params::certname, 
						$puppet_report= $::puppet::params::report, 
						$puppet_role= 'client',
						$puppet_firewall = $puppet::params::firewall
) inherits puppet::params {
	
	include ruby
	
	include puppet::repo::puppetlabs
	include puppet::repo::skettlerppa
	
	# Include augeas so the package is maintained and also we get all custom lenses
	include augeas
	
	# Include OS specific subclasses, if necessary
    case $::operatingsystem {
        ubuntu: { include puppet::ubuntu }
        debian: { include puppet::debian }
        windows: { include puppet::client::windows }
        default: { notify{"Module $module_name Class $name is not supported on os: $::operatingsystem, arch: $::architecture": } }
    }
    
    if $puppet_firewall { include puppet::config::firewall::client }
 
 	# Not required, as its part of the puppet package now.
	#package {"facter":
	#	ensure => latest,
	#	tag => "install-puppet",
	#	require => Package["puppet"],
	#	#require => [Class["puppet::repo::puppetlabs"], Exec['apt-get_update']],
	#}

	# Here we select to require a different repo for debian, this is due to some legeacy versions
	# not having puppet => 2.x in the debian repo.
	package {"puppet":
		#ensure => $::operatingsystem ? {
			# This is due to a current bug prevent puppet from running after loading facts
			# http://projects.puppetlabs.com/issues/12181
		#	redhat => "2.7.9-1.el5",
		#	default => latest,
		#	},
		ensure => $puppet::params::puppet_pkgversion,
		tag => "install-puppet",
		require => $::operatingsystem ? {
			ubuntu => [Class["puppet::repo::puppetlabs"], Exec["apt-get_update"]],
			debian => [Class["puppet::repo::puppetlabs"], Exec["apt-get_update"]],
			redhat => [Class["puppet::repo::puppetlabs"]],
			windows => undef,
			default => undef,
			}
	}

	case $::operatingsystem {
		'ubuntu': {
			package {"puppet-common":
				ensure => $puppet::params::puppet_pkgversion,
				tag => "install-puppet",
				require => $::operatingsystem ? {
					ubuntu => [Package["puppet"],Class["puppet::repo::puppetlabs"], Exec["apt-get_update"]],
					default => undef,
				}		
			}			
		}
	}  	
	
	service { "puppet":
		enable => $puppet_daemon ? {
      				true => true,
      				false => false,
      				default => $puppet_daemon,
    	},
		hasstatus => true,
		tag => "install-puppet",
		pattern => $::operatingsystem ? {
			Debian => "ruby /usr/sbin/puppetd -w 0",
			Ubuntu => "ruby /usr/sbin/puppetd -w 0",
			RedHat => "/usr/bin/ruby /usr/sbin/puppetd$",
 			CentOS => "/usr/bin/ruby /usr/sbin/puppetd$",
 			default => undef,
		}
	}
	
	## Created as part of package install, no longer required.
	#user { "puppet":
	#	ensure => present,
	#	require => Package["puppet"],
	#}
	
	# we use puppet.conf from svn for puppeteer
	# This is the only way I could think of to prevent the file being copied to the puppeteer!
	case $puppet_role {
        puppeteer: { 
        }
        default: {
        	file {"/etc/puppet/puppet.conf":
        		path => $puppet::params::configfile,
				ensure => present,
				owner => $puppet::params::configfile_owner,
				group => $puppet::params::configfile_group,
				mode => $puppet::params::configfile_mode,
				content => $puppet_role ? {
					'master' => template("puppet/master/puppet.conf.erb"),
					default => template("puppet/client/puppet.conf.erb"),
				},
				require => Package["puppet"],
			}
        }
    }	
	
	# Not required puppet runs handle dir permissions of puppet directories.
	#file {"/var/run/puppet/":
	#	ensure => directory,
	#	owner => "puppet",
	#	group => "puppet",
	#}
	
	# This gives us a folder to store temporary packages (debs/rpms/tar) etc.
	# It will only store files manganged by puppet and if need be we can remove at a later date
	# or if puppet is removed.
	file {"/etc/puppet-tmpfiles/":
		path => $puppet::params::tmpfiles_path,
		# We use this dir to store puppet msi's hence we need the dir
		# and file before we can upgrade puppet from its base install.
		#require => Package["puppet"],
		ensure => directory, # directory/absent
		recurse => true,
		purge => true,
		force => true, # Forces a removal if ensure => absent
		backup => false,
	}

	
	class windows inherits puppet::client {
		file { "/etc/puppet-tmpfiles/puppet-2.7.17.msi":
			path => "c:/puppet-tmpfiles/puppet-2.7.17.msi",
			require => File["/etc/puppet-tmpfiles/"],
    		ensure  => present,
    		source => "puppet:///ext-packages/puppet/puppet-2.7.17.msi"
    	}
    	File["/etc/puppet/puppet.conf"] {
    		owner => undef,
    		group => undef,
    		mode => undef,
    		content => template("puppet/client/puppet.conf-windows.erb"),
    	}
		Package["puppet"] {
			ensure => installed,
			provider => msi,
			notify => undef,
			require => undef,
			source => 'c:\puppet-tmpfiles\puppet-2.7.17.msi'
		}
		Service["puppet"] {
			enable => true
		}
	}


}
