# define: tcpwrapper::service
#
#	This define manages adding/removing/ammending entries to /etc/hosts.allow 
#	 using augeas and the custom lense
# 
# There is a feature requiest for a type/providor : http://projects.puppetlabs.com/issues/1556
# 
# tcpwrapper::addvalues is now a define in Ruby DSL, reaons explained in addvalues.rb
#
# Parameters:
#	$ensure = present|absent
#	$src = array of allow hosts/ips
#
# Actions:
#	1) Convert to templates? We don't ever know what was originally in the file, only what we add/maintain
#
# Requires:
#	a)	File hostsllow.aug in module tcpwrapper/files/lenses/
#	b)  class tcpwrapper
#
# Sample Usage:
#	Use a template locally in the environment or it will default to the defaults
#	You can then use the define to add and manage entries from the templates.
#
#
#	tcpwrapper::service { 'sshd':
#		ensure => 'present',
#		src => ['*.domain.com', '127.0.0.1', '192.168.1.1/255.255.255.0'],
#	}
#
# [Remember: No empty lines between comments and class definition]
define tcpwrapper::service($ensure, $servicename=$name, $src = []) {
#setup templates, lenses etc.
include tcpwrapper
	
	case $ensure {
    	present: {
    		augeas { "tcpwrapper-service-allow-$name" :
				load_path => '/usr/share/augeas/lenses/dist/:/usr/share/augeas/lenses/contrib/',
				context => "/files/etc/hosts.allow",
				changes => [
					# We use "00" as it will add to the end of the file
					# it will then be a sequential number once you view the tree again.
					"set 00/name '$name'", 
				],
				onlyif => "match *[name = '$servicename'] size == 0",
				require => File["/usr/share/augeas/lenses/contrib/hostsallow.aug"],
			}
			if $src {
				tcpwrapper::addvalues { "tcpwrapper-service-addvalues-${name}_${src}":
				process => $name,
				src => $src
			}	
			}
			
    	}
    	absent: {
    		 augeas { "tcpwrapper-service-disallow-$name" :
				load_path => '/usr/share/augeas/lenses/dist/:/usr/share/augeas/lenses/contrib/',
				context => "/files/etc/hosts.allow",
				changes => [
					# We use "00" as it will add to the end of the file
					# it will then be a sequential number once you view the tree again.
					"rm /files/etc/hosts.allow/*[name = '$name']",
				],
				#onlyif => "match /files/etc/apt/preferences/*[Package = '$package'] size == 0",
				require => File["/usr/share/augeas/lenses/contrib/hostsallow.aug"],
			}
   		}	
   	} #end case $enable

} #end define tcpwrapper::service