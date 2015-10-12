# Definition: splunk::define
#
# This class manages the defines used for the splunk classes
#
# Operating systems:
#	:Working
# 	:Testing
#		Ubuntu 10.04
#		RHEL5
#
# Parameters:
#
# Actions:
#	1) admin user will be passed as a variable from node definition or passed as parameter.
#
# Requires:
#
# Sample Usage:
#
#	## This is used to create and manage a dir in puppet for splunk
#	## Parameters:
#	#	name = dir location
#	splunk::manage_dir { "$splunk_path/etc/apps/search/local":
#
#	## This can be used on indexer/forwarder/client in order to get data into indexer.
#	## Parameters:
#	#	name = fully qualified log file or directory location
#	#	ensure = present/absent
#	splunk::define::monitor { "/var/log/messages": ensure => 'present'}
#
#	##
#	## Parameters:
#	#	name = listen port (splunks default is 9997)
#	#	ensure = present/absent
#	splunk::define::listen { "9997": ensure => 'present' }
#
#	##
#	## Parameters:
#	#	name = indexer IP address
#	#	ensure = present/absent
#	#	port = indexer port (defaults to 9997)
#	splunk::define::forward-server { "<indexer-ip>": ensure=> 'present', port => "<indexer-port>" }
#
#	## We can only add/delete users, we wont be changing passwords or roles
#	## as we cannot check if it "requires" changing and therefore puppet will constantly be editing
#	## the user giving possible false positives on puppet reports.
#	##
#	##	Parameters:
#	#	ensure = present/absent
#	#	name = $user = user name
#	#	passwd = users password = defaults to "changeme"
#	#	role = admin/user/power = defaults to "user"
#	splunk::define::manageuser { "<username>": ensure=> 'present', passwd => "<password>", role => "user" }
#
class splunk::define inherits splunk{

	# This allows us to pass the $splunk_path variable from different classes to create nessesary dirs
	define managedir() {

 		file { "$name":
 			ensure => directory, #make this a directory
			recurse => true, # enable recursive directory management
			purge => false, # purge all unmanaged junk
			force => false, # also purge subdirs and links etc.
			owner => "root",
			group => "root",
			mode => 0644, # this mode will also apply to files from the source directory
		}
		
	}
	
	# Maybe we can use defines to interact directly with the splunk api (./splunk <command>) etc..
	#define monitor( $ensure, $monitor="$name" ) {
		# Path ammended to allow the use of ./splunk within define
  	#	Exec { path => "/opt/splunk/bin/:/opt/splunkforwarder/bin/:/usr/bin:/usr/sbin/:/bin:/sbin" }
		
	#	if ($ensure == 'present') {
	#		exec { "splunk_add_monitor - $name":
    #  			command => "splunk add monitor '$monitor' -auth admin:changeme",
    #  			unless => "splunk list monitor -auth admin:changeme | grep -e '[^ ]$monitor'",
    # 			require => [Package["splunk"],Service["splunk"]],
	#		}
 	#	}elsif ($ensure == 'absent'){
 	#		exec { "splunk_remove_monitor - $name":
    #  			command => "splunk remove monitor '$monitor' -auth admin:changeme",
    #  			onlyif => "splunk list monitor -auth admin:changeme | grep -e '[^ ]$monitor'",
    # 			require => [Package["splunk"],Service["splunk"]],
	#		}
 	#	}
	#}
	
	define monitor($splunk_path, $type, $path="$name", $log_disabled = 'false') {
		concat::fragment{"monitor-${type}-${name}":
    		target  => "${splunk_path}/etc/system/local/inputs.conf",
    		#content => template("splunk/newmonitor-log.erb")
    		content => $type ? {
				log => template('splunk/fragments/monitor-log.erb'),
				file => template('splunk/fragments/monitor-fschange.erb'),
				default => template('splunk/fragments/monitor-log.erb')
				}
		}
    }

	# Adds a listen port to listen for incoming data from agents/forwarders
	define listen( $ensure, $port="$name" ) {
		# Path ammended to allow the use of ./splunk within define
  		Exec { path => "/opt/splunk/bin/:/opt/splunkforwarder/bin/:/usr/bin:/usr/sbin/:/bin:/sbin" }
		
		if ($ensure == 'present') {
			exec { "splunk_enable_listen":
      			command => "splunk enable listen -port $port -auth admin:changeme",
      			unless => "netstat -an | grep '0.0.0.0:$port'",
     			require => [Package["splunk"],Service["splunk"]],
			}
 		}elsif ($ensure == 'absent'){
 			exec { "splunk_disable_listen":
      			command => "splunk disable listen -port $port -auth admin:changeme",
      			onlyif => "netstat -an | grep '0.0.0.0:$port'",
      			require => [Package["splunk"],Service["splunk"]],
			}
 		}
	}
	
	# Adds a forward-server to send all data to the indexer
	# splunk add forward-server <host:port> -ssl-cert-path /path/ssl.crt -ssl-root-ca-path /path/ca.crt -ssl-password <password>
	#define forward-server( $ensure, $host="$name", $port="9997" ) {
	#	# Path ammended to allow the use of ./splunk within define
  	#	Exec { path => "/opt/splunk/bin/:/opt/splunkforwarder/bin/:/usr/bin:/usr/sbin/:/bin:/sbin" }
	#	
	#	if ($ensure == 'present') {
	#		exec { "splunk_add_forwardserver":
    #  			command => "splunk add forward-server $host:$port -auth admin:changeme",
    #  			unless => "splunk list forward-server -auth admin:changeme | grep -e '[^ ]$host:$port$'",
    #  			require => [Package["splunk"],Service["splunk"]],
	#		}
 	#	}elsif ($ensure == 'absent'){
 	#		exec { "splunk_remove_forwardserver":
    #  			command => "splunk remove forward-server $host:$port -auth admin:changeme",
    #  			onlyif => "splunk list forward-server -auth admin:changeme | grep -e '[^ ]$host:$port$'",
    # 			require => [Package["splunk"],Service["splunk"]],
	#		}
 	#	}
	#}
	define forwardserver($host="$name", $port) {
		concat::fragment{"forwardserver-${host}-${port}":
    		target  => "${splunk_path}/etc/system/local/outputs.conf",
    		content => template("splunk/fragments/forwardserver.erb")
    	}
    }

	# splunk edit user admin -password YOURNEWPASSWORD -auth admin:changeme
	define manageuser( $ensure, $user="$name", $passwd="changeme", $role="user" ) {
		# Path ammended to allow the use of ./splunk within define
  		Exec { path => "/opt/splunk/bin/:/opt/splunkforwarder/bin/:/usr/bin:/usr/sbin/:/bin:/sbin" }
		
		if ($ensure == 'present') {
			exec { "splunk_add_user":
      			command => "splunk add user $user -password $passwd -role $role -auth admin:changeme",
      			unless => "splunk list user -auth admin:changeme | grep -e '$user'",
     			require => [Package["splunk"],Service["splunk"]],
			}
 		}elsif ($ensure == 'absent'){
 			exec { "splunk_remove_user":
      			command => "splunk remove user $user -auth admin:changeme",
      			onlyif => "splunk list user -auth admin:changeme | grep -e '$user'",
     			require => [Package["splunk"],Service["splunk"]],
			}
 		}
	}

	
	# Used to control file system monitors (/opt/splunkforwarder/etc/system/default/inputs.conf)
	define fsmonitor() {
		
	}
	
	
}
