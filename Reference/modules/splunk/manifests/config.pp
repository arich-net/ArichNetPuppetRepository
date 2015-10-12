# Class Splunk::Config
#
# This class manages the defines used for the splunk classes. We needed to seperate into 
# indexers, forwarders and clients because of the use of /opt/splunk & /opt/splunkforwarders and 
# the fact I wasn't able to pass the $splunk_path variable to the define easily and cleanly. i.e I
# did not want to pass the dir path to each define call as this is inpractical.
# Yes its repeating some code, but it keeps it neat and tidy. :)
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
#
# Requires:
#
# Sample Usage:
#
#
class splunk::config() {

	class indexer() {
		
		define listen( $port="$name", $ssl, $sslrootca, $sslservercert, $sslpassphrase ) {
    		concat::fragment{"listen-${port}":
    			target  => "${splunk::params::splunk_indexer_path}/etc/system/local/inputs.conf",
    			content => template("splunk/fragments/indexerlisten.erb")
    		}
    	}
    	
	}
	
	class forwarder() {
	    
	    define forwardserver($host="$name", $port, $ssl, $sslrootca, $sslservercert, $sslpassphrase) {
			concat::fragment{"forwardserver-${host}-${port}":
    			target  => "${splunk::params::splunk_forwarder_path}/etc/system/local/outputs.conf",
    			content => template("splunk/fragments/forwardserver_forwarder.erb")
    		}
    	}
    	
    	define listen( $port="$name", $type="splunktcp", $index=undef ) {
    		concat::fragment{"listen-${port}-${port}":
    			target  => "${splunk::params::splunk_forwarder_path}/etc/system/local/inputs.conf",
    			content => $type ? {
    				tcp => template('splunk/fragments/listen-tcp.erb'),
    				splunktcp => template('splunk/fragments/listen-splunktcp.erb'),
    				udp => template('splunk/fragments/listen-udp.erb'),
    				default => template('splunk/fragments/listen-splunktcp'),
    			}
    		}
    	}
    	
    	define monitor($type, $path="$name", $log_disabled=false, $index=undef, $signedaudit=undef, $sourcetype=undef) {
			concat::fragment{"monitor-${type}-${name}":
	    		target  => "${splunk::params::splunk_forwarder_path}/etc/system/local/inputs.conf",
	    		content => $type ? {
					log => template('splunk/fragments/monitor-log.erb'),
					file => template('splunk/fragments/monitor-fschange.erb'),
					default => template('splunk/fragments/monitor-log.erb')
					}
			}
	    }
    		
    	
	}

	class client() {
			
		define monitor($type, $path="$name", $log_disabled=false, $index=undef, $signedaudit=undef, $sourcetype=undef) {
			concat::fragment{"monitor-${type}-${name}":
	    		target  => "${splunk::params::splunk_client_path}/etc/system/local/inputs.conf",
	    		content => $type ? {
					log => template('splunk/fragments/monitor-log.erb'),
					file => template('splunk/fragments/monitor-fschange.erb'),
					default => template('splunk/fragments/monitor-log.erb')
					}
			}
	    }
	    
	    define forwardserver($host="$name", $port) {
			concat::fragment{"forwardserver-${host}-${port}":
    			target  => "${splunk::params::splunk_client_path}/etc/system/local/outputs.conf",
    			content => template("splunk/fragments/forwardserver_client.erb")
    		}
    	}	
		
	}

	
	
}
