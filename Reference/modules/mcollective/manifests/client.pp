# Class: mcollective::client
#
# This module manages mcollective for the client (the server)
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
class mcollective::client($stomphost = ['213.130.39.1', '213.130.39.2', '213.130.39.33', '91.186.178.50'], $stompport = '6163') {
	include mcollective
  	package {"mcollective-client":
    	ensure => "latest",
		require => [Package["mcollective-common"], Class["puppet::repo::puppetlabs"], Exec['apt-get_update']],
  	}
  
  	file {"/etc/mcollective/client.cfg":
    	content => template("mcollective/client.cfg"),
    	require => [Package["mcollective-common"],Package["mcollective-client"]],
  	}

}