# Class: sysfirewall
#
# IMPORTANT **** Please pay close attention when using this class/type as all ruleas have
#	have to be numbered sequentially to give order when puppet applies them.
#
# Core firewall type, forked from https://github.com/puppetlabs/puppetlabs-firewall,
# No need to reinvent the wheel!
#
# This gives you access to use the firewall resource in any node/class definition.
#
# Parameters:
#	Rules are adding in sequential order based on resource name "001 <myrule>", for this reason
#	I will allocate a pool of numbers for pre, custom and post.
#	
#	Pre rules as defined in firewall::pre = 000 > 099
#	Custom rules, can be defined across entire catalog = 100 > 899
#	All rules within modules will use "200", there will be no "order" but it will allow pre rules.
#	Post rules as defined in firewall::post = 900 > 999
#
# Actions:
#	1) when resource is set to purge, non puppet managed rules are removed but a notify exec is not called.
#
# Requires:
#
# Sample Usage:
#	include sysfirewall
#		Adds the ability to support the firewall type hence class is not named "firewall"
#
#		# Can be called from anywhere in your catalog:
#		firewall { '000 accept all icmp':
#			proto   => 'icmp',
#			action  => 'accept',
#		}
#
class sysfirewall() {
	
#	class { 'sysfirewall::pre': stage => 'pre' }
#	class { 'sysfirewall::post': stage => 'post' }
	include sysfirewall::pre
	include sysfirewall::post
		
	Class["sysfirewall::pre"] -> Firewall <| tag != "sysfirewall::pre" |>
	
	case $::operatingsystem {
      redhat: { include sysfirewall::redhat }
      /(?i)(debian|ubuntu)/: { include sysfirewall::debian }
      default: { notify{"Operating system not recognized by sysfirewall class": } }
    }
    class redhat {}
    class debian {
		package{'iptables-persistent': 
			ensure => installed,
		}
		service { "iptables-persistent":
			require => Package["iptables-persistent"],
			# There is no running process so I hard code the "status" variable,
			# this makes puppet think the service is always running.
			# I set hasrestart => false so that it uses start/stop rather then restart on the
			# init.d script
			hasstatus => true,
			status => "true",
			hasrestart => false,
		}
		
		# we need to set a file resource for /etc/iptables/rules and notify the above service
		# to use the restore function. At the moment the firewall resource is doing this.
  
    }
	
	# purge all non puppet managed rules.
	resources { "firewall":
		purge => true
	}

}