node 'evl3301836.eu.verio.net' {
        notify {"Welcome to Nagios LAB Test": }
	#class { "nagios::server":
	#   nagios_config_file_path => "/opt/roberto/test",
        #}
        include nagios::server
}
