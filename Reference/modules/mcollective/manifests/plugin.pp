# Class: mcollective::plugin
#
# This module manages mcollective plugin deployments
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
define mcollective::plugin($type = "agent") {


	# This is a tricky one.
	# .dll are deployed to both clients & servers.
	# For windows we only use the single server package as its never a client...
	#	Therefore we use the case statement for the require to get around the dependency issues.
	#
	if ($type == "agent") {
	   	file {"${mcollective::params::lib_dir}/mcollective/${type}/${name}.ddl":
	    	source => "puppet:///mcollective/plugins/${type}/${name}/agent/${name}.ddl",
	    	owner => $mcollective::params::owner,
			group => $mcollective::params::group,
			mode => $mcollective::params::mode,
	    	#require => Package["mcollective-common"],
	    	require => $::operatingsystem ? {
						windows => Package["mcollective"],
						default => Package["mcollective-common"],
			}
	  	}
  	}
  		
	# This is for MCO Server
	if defined (Class['mcollective::server']) {
    
		file {"${mcollective::params::lib_dir}/mcollective/${type}/${name}.rb":
			source => "puppet:///mcollective/plugins/${type}/${name}/agent/${name}.rb",
			#source => $type ? {
			#	'agent' => "puppet:///mcollective/plugins/${type}/${name}/agent/${name}.rb",
			#	'facts' => "puppet:///mcollective/plugins/${type}/${name}/${name}.rb",
			#},
			owner => $mcollective::params::owner,
			group => $mcollective::params::group,
			mode => $mcollective::params::mode,
			require => Package["mcollective"],
			notify => Service["mcollective"],
		}
		    	
	}
	
	# This is for MCO Client
	if defined (Class['mcollective::client']) {
        if ($type == "agent") {
	    	file {"${mcollective::params::lib_dir}/mcollective/application/${name}.rb":
	      		mode => $mcollective::params::mode,
	      		owner => $mcollective::params::owner,
				group => $mcollective::params::group,
	      		source => "puppet:///mcollective/plugins/${type}/${name}/application/${name}.rb",
	      		require => Package["mcollective-common"],
	    	}
	    }

    }
    
}