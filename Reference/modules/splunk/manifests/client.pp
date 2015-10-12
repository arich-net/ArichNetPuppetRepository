# Class: splunk::client
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
#	indexer = Where to send data
#
# Actions:
#
# Requires:
#
# Sample Usage:
#	class { 'splunk::client':
#		indexer => '1.2.3.4',
#		port => '9997',		
#   disablehttpserver => 'true',
#	}
#
#	Inputs.conf
#		
#		$logmonitor =  {
#   		1 => { 'path' => '/var/log/test/', 'disabled' => 'false' },
#		}
#		$fschangemonitor =  {
#   		1 => { 'path' => '/root/test/' },
#		}
#
# [Remember: No empty lines between comments and class definition]
class splunk::client($indexer='', $indexerport='9997', $disablehttpserver='false' ) inherits splunk {
	
	include splunk::config::firewall::client
    
	# Used for init.d splunk template
	$splunk_path = "${splunk::params::splunk_client_path}"
		
	# Copy universal forwarder
	file { "$splunk::params::splunk_file_path_local$splunk::params::splunk_client_pkg":
    		owner   => root,
    		group   => root,
    		mode    => 644,
    		ensure  => present,
    		source  => "${splunk::params::splunk_file_path_remote}${splunk::params::splunk_client_pkg}",
	}
	
	# We need this to match the package resource in indexer.pp & forwarder.pp
	# as we are using require => Package["splunk"] in define.pp
	# and within define.pp there is no way of determining the name of the package resource
	# being used.
	package { "splunk":
		name => "splunkforwarder", # This is what puppet will use to search dpkg --list for.
    	ensure => latest,
    	provider => "${splunk::params::provider}",
    	source => "${splunk::params::splunk_file_path_local}${splunk::params::splunk_client_pkg}",
		  require => File["$splunk::params::splunk_file_path_local$splunk::params::splunk_client_pkg"],
    	before => Service["splunk"],
	}
	service { splunk:
		    name => "splunk",
		    ensure => running,
      	enable => true,
      	hasrestart => true,
      	hasstatus => false,
      	pattern => "splunkd",
		    require => [
					File["/etc/init.d/splunk"],
					Package["splunk"],
				],
		    subscribe => [ File["/opt/splunkforwarder/etc/system/local/inputs.conf"], 
				  		         File["/opt/splunkforwarder/etc/system/local/outputs.conf"],
				  		         File["/opt/splunkforwarder/etc/system/local/server.conf"],
		    ]
	}
	
	# Init script (Based on `/opt/splunk/bin/splunk enable boot-start`)
	file { "/etc/init.d/splunk":
		owner => root, group => root, mode => 755,
		content => template("splunk/init-script.erb"),
		require => [ Package["splunk"] ],
	}
	
	file { "${splunk_path}/etc/system/local/server.conf":
    owner   => root,
    group   => root,
    mode    => 644,
    require => [ Package["splunk"] ],
    content => template("splunk/client/etc/system/local/server.conf.erb"),
	}
	
	concat { "${splunk_path}/etc/system/local/inputs.conf":
		owner   => root,
		group   => root,
		mode    => 644,
		require => [ Package["splunk"] ],
	}
	
	concat { "${splunk_path}/etc/system/local/outputs.conf":
		owner   => root,
		group   => root,
		mode    => 644,
		require => [ Package["splunk"] ],
	}
	
	concat::fragment { "inputs.conf.erb":
		target  => "${splunk_path}/etc/system/local/inputs.conf",
		content => template("splunk/client/etc/system/local/inputs.conf.erb"),
		order   => 01,
	}
	
	concat::fragment { "outputs.conf.erb":
		target  => "${splunk_path}/etc/system/local/outputs.conf",
		content => template("splunk/client/etc/system/local/outputs.conf.erb"),
		order   => 01,
	}
	
	# Add forward server
	splunk::config::client::forwardserver { "$indexer": port => "$indexerport" }

}