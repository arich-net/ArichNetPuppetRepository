# Class: tcpwrapper
#
# This module manages tcpwrappers (hosts.allow | hosts.deny)
#	We will deny ALL:ALL and only use hosts.allow to manage daemon access.
#
# This downloads a template from your local environment templates or defaults
# to core/tcpwrappers/templates. You can then add/remove/modify entries using the defines.
# 
# There is a feature requiest for a type/providor : http://projects.puppetlabs.com/issues/1556
# 
# Parameters:
#
# Actions:
#
# Requires:
#
# Sample Usage:
#	Use a template locally in the environment or it will default to the defaults
#	You can then use the define to add and manage entries from the templates.
#
#
#	tcpwrapper::service { 'sshd':
#		ensure => 'present',
#		src => '192.168.1.1/255.255.0.0,127.0.0.1',
#	}
#
# [Remember: No empty lines between comments and class definition]
class tcpwrapper() {

#	file { "/etc/hosts.allow":
#		#content => template("tcpwrapper/hosts.allow.erb"),
#		mode => 0644, owner => root, group => root,
#		#Using inline_template this needs to be full path
#		content => inline_template(
#			file(
#				"/etc/puppet/environments/$environment/templates/tcpwrapper/hosts.allow.erb",
#				"/etc/puppet/modules/core/tcpwrapper/templates/hosts.allow.erb"
#			)
#		),
#	}
#	file { "/etc/hosts.deny":
#		#content => template("tcpwrapper/hosts.allow.erb"),
#		mode => 0644, owner => root, group => root,
#		#Using inline_template this needs to be full path
#		content => inline_template(
#			file(
#				"/etc/puppet/environments/$environment/templates/tcpwrapper/hosts.deny.erb",
#				"/etc/puppet/modules/core/tcpwrapper/templates/hosts.deny.erb"
#			)
#		),
#	}

	# For the time being we will remove the dist version.
	# The reason for this, is that the dist version requires a process and a value to be set
	# before a write and it causes headaches with arrays.

	# Remove, so there is no conflict on /etc/hosts.allow
	file { "/usr/share/augeas/lenses/dist/hosts_access.aug":
		ensure => absent
	}
	file { "/usr/share/augeas/lenses/contrib/hostsallow.aug":
    		mode => 0644,
    		owner => "root",
    		group => "root",
    		source  => "puppet:///modules/tcpwrapper/lenses/hostsallow.aug",
  		}

  		
  		  		
}