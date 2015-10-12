# Define: tcpwrapper::service::addvalues
#
# Parameters:
#	$name is given from call to the define in tcpwrapper::service
#	$servicename is given from the call to the define in tcpwrapper::service
#
# Actions:
#
# Requires:
#	a) tcpwrapper::service (service.pp)
#
# Sample Usage: 
#
# [Remember: No empty lines between comments and class definition]
#define tcpwrapper::addvalues($servicename, $src) {
#	augeas { "tcpwrapper-service-$servicename add-value-$name" :
#		load_path => '/usr/share/augeas/lenses/dist/:/usr/share/augeas/lenses/contrib/',
#		context => "/files/etc/hosts.allow",
#		changes => [
#			"set *[name = '$servicename']/value[last()+1] '$src'",
#		],
#		onlyif => "match *[name = '$servicename']/value[.= '$name'] size == 0",
#		require => Augeas["tcpwrapper-service-allow-$servicename"],
#	}
#}