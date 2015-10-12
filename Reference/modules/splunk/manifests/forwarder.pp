# Class: splunk::forwarder
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
#	indexer = Where to send data (optional) but if this is a forwarder is should be set to the indexer.
#	indexerport = what port is the indexer listening on (defaults 9997)
#	localreceiveport = which port to listen for data from agents (defaults to 9997)
#	storelogs = Shall we store a local copy of logs (defaults to false) (indexAndForward = 0)
#	ssl	= true/false = boolean
#	sslrootca = filename of rootca certificate
#	sslservercert = filename of server certiicate
#	sslpassphrase = passphrase of server cert 
#
# Actions:
#	1) create a hash array for specifing multiple tcp/udp ports with keys for parameters etc.
#		At the moment only one tcp and one udp input are supported.
#		"port" > "514", "index > "test" 
#
# Requires:
#
# Sample Usage:
#
# [Remember: No empty lines between comments and class definition]
class splunk::forwarder(	$indexer, 
							$indexerport = '9997',
							$tcpinputport = '9997',
							$tcpinputindex = undef,
							$udpinputport = '514',
							$udpinputindex = undef,
							$ssl = false,
							$sslrootca = undef,
							$sslservercert = undef,
							$sslpassphrase = undef
) inherits splunk {
	
	include splunk::config::firewall::forwarder

    
	# Used for init.d splunk template
	$splunk_path = '/opt/splunk'
	
	# Create files/dirs
	#splunk::define::managedir { "$splunk_path/etc/system/local": }
	
	# Copy forwarder
	file { "$splunk::params::splunk_file_path_local$splunk::params::splunk_forwarder_pkg":
    		owner   => root,
    		group   => root,
    		mode    => 644,
    		ensure  => present,
    		source  => "${splunk::params::splunk_file_path_remote}${splunk::params::splunk_forwarder_pkg}",
	}
	package { "splunk":
    	ensure => latest,
    	provider => "${splunk::params::provider}",
    	source => "${splunk::params::splunk_file_path_local}${splunk::params::splunk_forwarder_pkg}",
    	require => File["$splunk::params::splunk_file_path_local$splunk::params::splunk_forwarder_pkg"],
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
	
	# Use this if you want to override the service in sub classes
	#Service['splunkforwarder'] {
	#	require => Package["splunkforwarder"],
	#	subscribe => Package["splunkforwarderat"],
    #}
	
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
	
	concat { "${splunk_path}/etc/system/local/outputs.conf":
		owner   => root,
		group   => root,
		mode    => 644,
		require => [ Package["splunk"] ],
	}
	
	concat::fragment { "inputs.conf.erb":
		target  => "${splunk_path}/etc/system/local/inputs.conf",
		content => template("splunk/forwarder/etc/system/local/inputs.conf.erb"),
		order   => 01,
	}
	
	concat::fragment { "outputs.conf.erb":
		target  => "${splunk_path}/etc/system/local/outputs.conf",
		content => template("splunk/forwarder/etc/system/local/outputs.conf.erb"),
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
		owner   => splunk,
		group   => splunk,
		mode    => 644,
		recurse => true,
		purge => true,
		force => true,
		source => [ "puppet:///files-environment/$::environment/files/splunk/certs",
					"puppet:///modules/splunk/certs"
		],
	}
  	
	# Setup listen port
	splunk::config::forwarder::listen { "$tcpinputport":
		type => "splunktcp",
		index => $tcpinputindex
	}
	splunk::config::forwarder::listen { "$udpinputport":
		type => "udp",
		index => $udpinputindex
	}
	
	# Forward data to Indexer
	splunk::config::forwarder::forwardserver { "$indexer": 
		port => "$indexerport",
		ssl => $ssl,
		sslrootca => "$sslrootca",
		sslservercert => "$sslservercert",
		sslpassphrase => "$sslpassphrase"
	}

   
    
} # end splunk::forwarder












#### NOTES

    ## Begin outputs.conf hack; summary:
    
    # If we manage outputs.conf with plaintext Splunk and Puppet will fight
    # over the file with Splunk crypting the plaintext and Puppet replacing it
    # If we manage a proxy file and then trigger a command to copy the file to
    # the file Splunk is expecting it will work fine. In the exec we notify
    # the Splunk service so that it restarts when it picks up the new
    # outputs.conf file.
#    file { "/opt/splunk/etc/system/local/outputs.conf-PUPPET":
#      owner => splunk, group => splunk, mode => 400,
#      source => [
#        "puppet:///modules/splunk/etc/system/local/lwf-output.conf.$fqdn",
#        "puppet:///modules/splunk/etc/system/local/lwf-output.conf",
 #     ],
 ##     require => Package['splunk'],
 #     notify => Exec['move-outputs.conf'],
 #   }
#    exec { "move-outputs.conf":
#      command => "/bin/cp -f /opt/splunk/etc/system/local/outputs.conf-PUPPET /opt/splunk/etc/system/local/outputs.conf ; /bin/chown splunk:splunk /opt/splunk/etc/system/local/outputs.conf ; /bin/chmod 600 /opt/splunk/etc/system/local/outputs.conf",
#      refreshonly => true,
# #     notify => Service['splunk'],
#    }
#    
#    ## End outputs.conf hack
#    
#    file { "/opt/splunk/etc/apps/SplunkLightForwarder":
#      owner => splunk, group => splunk, mode => 600,
#      recurse => true,
#      purge => false,
#      source => [
#        "puppet:///modules/splunk/etc/apps/SplunkLightForwarder.$fqdn",
#        "puppet:///modules/splunk/etc/apps/SplunkLightForwarder",
#      ],
#      require => Package['splunk'],
#    }
#    file { "/opt/splunk/etc/certs/forwarder.pem":
#      owner => splunk, group => splunk, mode => 600,
#      source => [
 #       "puppet:///modules/splunk/etc/certs/$fqdn.pem",
 #       "puppet:///modules/splunk/etc/certs/forwarder.pem",
#      ],
#      require => Package['splunk'],
#    }
##    