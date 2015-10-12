# Class: mcollective
#
# This module manages mcollective
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
class mcollective {
	include mcollective::params
	include puppet::repo::puppetlabs

	# Agents
	mcollective::plugin {"puppetd": type => "agent",}
	mcollective::plugin {"package": type => "agent",}
	mcollective::plugin {"service": type => "agent",}
	mcollective::plugin {"stomputil": type => "agent",}
	mcollective::plugin {"mcoaudit": type => "audit",}
	mcollective::plugin {"serverqa": type => "agent",}
	mcollective::plugin {"bootstrap": type => "agent",}


	# Temporary fix as mcollective-common should be a dependency of both
	# mcollective-server & mcollective-client, hence shouldn't need managing with puppet.
	case $::operatingsystem {
        windows: { }
        default: { 
	        package {"mcollective-common":
			# Error in deb package causing an error when upgrading to 2.x
	  		# https://projects.puppetlabs.com/issues/14277
	  		# For now I will static set to existing v1.2
	    	#ensure => "1.2.1-1",
	    	ensure => $mcollective::params::pkg_version,
	    	require => $::operatingsystem ? {
				ubuntu => [Class["puppet::repo::puppetlabs"], Exec['apt-get_update']],
				debian => [Class["puppet::repo::puppetlabs"], Exec['apt-get_update']],
				redhat => [Class["puppet::repo::puppetlabs"]],
				centos => [Class["puppet::repo::puppetlabs"]],
				windows => undef,
				default => undef,
				}
  			}
        }
    }
  	
  	#
  	# Due to libstomp not being in 8.04 repo we download the package.
  	#
  	case $::lsbdistcodename {
		/(?i)(hardy|lucid|lenny)/: {
			file { "/etc/puppet-tmpfiles/libstomp-ruby1.8_1.1.9-0ubuntu1_all.deb":
    			owner   => root,
    			group   => root,
    			mode    => 644,
    			ensure  => present,
    			source => "puppet:///ext-packages/mcollective/libstomp-ruby1.8_1.1.9-0ubuntu1_all.deb"
    		}
    		file { "/etc/puppet-tmpfiles/libstomp-ruby_1.1.9-0ubuntu1_all.deb":
    			owner   => root,
    			group   => root,
    			mode    => 644,
    			ensure  => present,
    			source => "puppet:///ext-packages/mcollective/libstomp-ruby_1.1.9-0ubuntu1_all.deb"
    		}
			package { "libstomp-ruby1.8":
    			provider => dpkg,
    			ensure => latest,
    			source => "/etc/puppet-tmpfiles/libstomp-ruby1.8_1.1.9-0ubuntu1_all.deb"
  			}
  			package { "libstomp-ruby":
    			provider => dpkg,
    			ensure => latest,
    			source => "/etc/puppet-tmpfiles/libstomp-ruby_1.1.9-0ubuntu1_all.deb",
    			require => Package['libstomp-ruby1.8'],
  			}	
		}
		default: {
          	# Use standard package as default
			package {"rubygem-stomp":
				name => $::operatingsystem ? {
	  				ubuntu => "libstomp-ruby",
	  				debian => "libstomp-ruby",
	  				redhat => "rubygem-stomp",
	  				centos => "rubygem-stomp",
	  				windows => "stomp",
				    default => "libstomp-ruby",
				},
    			#ensure => "latest",
    			ensure => $::operatingsystem ? {
    			  windows => "1.2.2", # need to check compat with activemq connector 
    			  default => latest
    			},
    			provider => $::operatingsystem ? {
    				windows => gem,
    				default => undef,
    				},
    			require => $::operatingsystem ? {
					ubuntu => [Class["apt"], Exec['apt-get_update']],
					debian => [Class["apt"], Exec['apt-get_update']],
					redhat => [Class["yum"], Exec['yum_update']],
					centos => [Class["yum"], Exec['yum_update']],
					windows => undef,
					default => undef,
					}
  			}
		}
    }

	
#	file {"${mcollective::params::lib_dir}/mcollective":
#		ensure => directory,
#		owner => 'root',
#		group => 'root',
#		mode => '0755',
#   	require => Package["mcollective-common"],
#}


}

# Redhat
# yum install rubygems
# yum install rubygem-stomp
# rpm -Uvh http://yum.puppetlabs.com/el/5/products/i386/mcollective-common-1.2.1-1.el5.noarch.rpm

# Debian
# mcollective client
# libdir = /usr/share/mcollective/plugins

# RabbitMQ
# Ensure plugin version matches rabbitmq-server package ver.
