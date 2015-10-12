# Class: splunk::indexer
#
# This module manages the installation of the Splunk universal forwarder
#
# Operating systems:
#	:Working
#
# 	:Testing
#		Ubuntu 10.04
#		RHEL5
#
# Parameters:
#	localreceiveport = which port to listen for data from agents/forwarders (defaults to 9997)
#	storelogs = Shall we store a local copy of logs (defaults to true) (indexAndForward = 1)
#
# Actions:
#
# Requires:
#
# Sample Usage:
#
# [Remember: No empty lines between comments and class definition]
class splunk::indexer( $localreceiveport='9997',
						$ssl = false,
						$sslrootca = undef,
						$sslservercert = undef,
						$sslpassphrase = undef
) inherits splunk {
	
	include splunk::config::firewall::indexer
    
	# Used for init.d splunk template
	$splunk_path = '/opt/splunk'
	
	# Create files/dirs
	#splunk::define::managedir { "$splunk_path/etc/apps/search/local": }
	#splunk::define::managedir { "$splunk_path/etc/system/local": }
	
	# Copy splunk
	file { "$splunk::params::splunk_file_path_local$splunk::params::splunk_indexer_pkg":
    		owner   => root,
    		group   => root,
    		mode    => 644,
    		ensure  => present,
    		source  => "${splunk::params::splunk_file_path_remote}${splunk::params::splunk_indexer_pkg}",
	}
	package { "splunk":
    	ensure => latest,
    	provider => "${splunk::params::provider}",
    	source => "${splunk::params::splunk_file_path_local}${splunk::params::splunk_indexer_pkg}",
    	require => File["$splunk::params::splunk_file_path_local$splunk::params::splunk_indexer_pkg"],
    	before => Service["splunk"],
	}
	service { splunk:
		name => "splunk", # what to look for in init.d
		ensure => running,
      	enable => true,
      	hasrestart => true,
      	hasstatus => false,
      	pattern => "splunkd",
		require => [
					File["/etc/init.d/splunk"],
					Package["splunk"],
					],
      	#subscribe => File["/etc/init.d/splunk"],
	}
	
	# Init script (Based on `/opt/splunk/bin/splunk enable boot-start`)
	file { "/etc/init.d/splunk":
		owner => root, group => root, mode => 755,
		content => template("splunk/init-script.erb"),
		require => [ Package["splunk"] ],
	}
	
	concat { "${splunk_path}/etc/system/local/inputs.conf":
		owner   => root,
		group   => root,
		mode    => 644,
		require => [ Package["splunk"] ],
	}
	
	concat::fragment { "inputs.conf.erb":
		target  => "${splunk_path}/etc/system/local/inputs.conf",
		content => template("splunk/indexer/etc/system/local/inputs.conf.erb"),
		order   => 01,
	}
	
	#
	# Certificates
	#
	file { "${splunk_path}/etc/certs":
		ensure => $ssl ? {
			true => directory,
			false => absent,
			default => absent
		},
		require => [ Package["splunk"] ],
		recurse => $ssl ? {
			true => true,
			false => false,
			default => false
		},
		purge => true,
		force => true,
		source => [ "puppet:///files-environment/$::environment/files/splunk/certs",
					"puppet:///modules/splunk/certs"
		],
	}
	
	# Setup listen port
	splunk::config::indexer::listen { "$localreceiveport": 
		ssl => $ssl,
		sslrootca => "$sslrootca",
		sslservercert => "$sslservercert",
		sslpassphrase => "$sslpassphrase"
	}
		
	
} #End splunk::indexer

