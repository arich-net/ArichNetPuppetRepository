# Class: mcollective::server
#
# This module manages mcollective for the server (nodes)
#
# Parameters:
#	$stomphost = Array of ActiveMQ hosts, iterated in the server.cfg tpl
#	$stompport = stompport on the activeMQ server.
#	$identity = identity param in server.cfg. (incase you need something other then FQDN,
#				 or using a different certname)
#
# Actions:
#
# Requires:
#
# Sample Usage:
#	Firwall rules are automagically created for all stomphost IP's when sysfirewall class is defined
#
# [Remember: No empty lines between comments and class definition]
class mcollective::server( $stomphost = [	'213.130.39.1',
											'213.130.39.2',
											'10.231.39.2',
											'213.130.39.33',
											'10.130.39.33', 
											'91.186.178.50',
											'10.198.178.50',
											'213.130.57.12',
											'10.19.57.12',
											'83.231.220.68',
											'10.26.220.68',
											'83.217.251.100',
											'10.20.251.100',
											
], 
							$stompport = '6163',
							$identity = $::mcollective::params::identity
) {
  	include mcollective
  	
	mcollective::config::firewall::server { $stomphost: }
    
    case $::operatingsystem {
        windows: { include mcollective::server::windows }
        /(?i)(ubuntu|debian)/: { include mcollective::server::ubuntu  }
        /(?i)(centos|redhat)/: {  }
        default: { notify{"Module $module_name is not supported on os: $::operatingsystem, arch: $::architecture": } }
    }
    
    case $::lsbdistcodename {
    	wheezy: { include mcollective::server::wheezy }
    }

	# Ugly hack :), we all love those!
	# We should remove this when mcollective packages from puppetlabs have fixed the issue.
	# http://projects.puppetlabs.com/issues/16572    
    class wheezy() inherits mcollective::server {
		exec {'fix_ruby18':
			command => "sed 's/env ruby/env ruby1.8/' -i /usr/sbin/mcollectived",
			refreshonly => true,
			subscribe => Package["mcollective"],
			notify => Service["mcollective"],
		}    	
    }
    
  	package {"mcollective":
  		# Error in deb package causing an error when upgrading to 2.x
  		# https://projects.puppetlabs.com/issues/14277
  		# For now I will static set to existing v1.2
    	#ensure => "1.2.1-1",
    	ensure => $mcollective::params::pkg_version,
    	notify => Service["mcollective"],
    	# Due to a case selector in init.pp, needs rewrite and put in params.pp
    	require => $::lsbdistcodename ? {
			/(?i)(hardy|lucid|lenny)/ => [Package["mcollective-common"], Class["puppet::repo::puppetlabs"]],
			default => [Package["mcollective-common"], Package["rubygem-stomp"], Class["puppet::repo::puppetlabs"]],
		}
  	}
	
	file {"/etc/mcollective/server.cfg":
		path => $mcollective::params::server_cfg_path,
    	content => template("mcollective/server.cfg"),
    	require => Package["mcollective"],
    	notify => Service["mcollective"],
  	}

	file { "${mcollective::params::lib_dir}/mcollective/facts/":
		path => "${mcollective::params::lib_dir}/mcollective/facts/",
		owner => $mcollective::params::owner,
		group => $mcollective::params::group,
		mode => $mcollective::params::mode,
		#purge => true,
		source => "puppet:///mcollective/plugins/facts/",
		recurse => true,
		require => Package["mcollective"]
	}
	
	file { "${mcollective::params::base_dir}/ssl/":
		path => "${mcollective::params::base_dir}/ssl/",
		owner => $mcollective::params::owner,
		group => $mcollective::params::group,
		mode => $mcollective::params::mode,
		#purge => true,
		source => "puppet:///mcollective/ssl/",
		recurse => true,
		require => Package["mcollective"]
	}
	
	file { "${mcollective::params::lib_dir}/mcollective/data/":
		path => "${mcollective::params::lib_dir}/mcollective/data/",
		owner => $mcollective::params::owner,
		group => $mcollective::params::group,
		mode => $mcollective::params::mode,
		#purge => true,
		source => "puppet:///mcollective/plugins/data/",
		recurse => true,
		require => Package["mcollective"]
	}
	
	file { "${mcollective::params::lib_dir}/mcollective/registration/":
		path => "${mcollective::params::lib_dir}/mcollective/registration/",
		owner => $mcollective::params::owner,
		group => $mcollective::params::group,
		mode => $mcollective::params::mode,
		#purge => true,
		source => "puppet:///mcollective/plugins/registration/",
		recurse => true,
		require => Package["mcollective"]
	}	
	
	file { "${mcollective::params::lib_dir}/mcollective/security/":
		path => "${mcollective::params::lib_dir}/mcollective/security/",
		owner => $mcollective::params::owner,
		group => $mcollective::params::group,
		mode => $mcollective::params::mode,
		#purge => true,
		source => "puppet:///mcollective/plugins/security/",
		recurse => true,
		require => Package["mcollective"]
	}	

	file{"/etc/mcollective/scope_facts.yaml":
		path => $mcollective::params::scope_facts_path,
    	owner => $mcollective::params::owner,
    	group => $mcollective::params::group,
    	mode => $mcollective::params::mode,
    	# avoid including highly-dynamic facts as they will cause unnecessary
		# template writes
		# There is a bug that causes puppet to write out the below to yaml format, this keeps changing so we
		# use "sym" to remove it
		# "--- !ruby/sym _timestamp": 2011-12-07 01:52:43
		# http://projects.puppetlabs.com/issues/6299#change-25770
    	content => inline_template("<%= scope.to_hash.reject { |k,v| k =~ /(memoryfree|swapfree|uptime|sym)/ || !( k.is_a?(String) && v.is_a?(String) ) }.to_yaml %>"),
    	#content => inline_template("<%= (scope.to_hash.reject { |k,v| k =~ /(memoryfree|swapfree|uptime|sym)/ || !( k.is_a?(String) && v.is_a?(String) ) }.to_a - Facter.to_hash.to_a).inject({}) {|r, val| r[val[0]] = val[1]; r}.to_yaml %>"),
#    	loglevel => debug,
    	require => Package["mcollective"],
  	}
  	
  service {"mcollective":
    ensure => running,
    enable => true,
#    hasstatus => true,
#    hasrestart => true,
    require => Package["mcollective"],
  }

  class ubuntu() inherits mcollective::server {
    apt::preferences { 'mcollective':
      ensure => 'present',
      package => 'mcollective',
      pin => 'version',
      pin_value => $mcollective::params::pkg_version,
      priority => '950',
    }

    apt::preferences { 'mcollective-common':
      ensure => 'present',
      package => 'mcollective-common',
      pin => 'version',
      pin_value => $mcollective::params::pkg_version,
      priority => '950',
    }    
  }

	class windows() inherits mcollective::server {

		#
		# Temporary to update the environments to include Facter libs
		# Could make permanant if we need to manage this?
		# environment.bat needs updating in the msi to include facter lib path
		##############
		case $::env_windows_installdir {
    		/(?i)(x86)/:{
    			$base_folder = 'c:\Program Files (x86)\MCollective'
    		}
    		default:{
    			$base_folder = 'c:\Program Files\MCollective'
    		}
    	}
    	
    	
		file { "${base_folder}/bin/":
			path => "${base_folder}/bin/",
			owner => $mcollective::params::owner,
			group => $mcollective::params::group,
			mode => $mcollective::params::mode,
			source => "puppet:///mcollective/windows/bin/",
			recurse => true,
			require => Package["mcollective"]
		}
		
		exec {'unregister_service':
			path => $::path,
			command => "cmd /c \"${base_folder}\\bin\\unregister_service.bat\"",
			refreshonly => true,
			subscribe   => File["${base_folder}/bin/"],
		}

		exec {'register_service':
			path => $::path,
			command => "cmd /c \"${base_folder}\\bin\\register_service.bat\"",
			refreshonly => true,
			subscribe   => Exec["unregister_service"],
		}

    # This is temporay to ensure the newest (not working) gem is removed.
    # This was added after the windows boxes automatically upgraded themself to an
    # unsupported version.
    # the stomp version is now hardcoded to a known working version.
    # I may add other versions but so far just 1.3.1 is showing issues. 
    # This can also be commented out when I am satisfied all windows
    # boxes have run, which is why I haven't added an 'onlyif =>'
    exec { 'remove-stomp_1_3_0':
      path => $::path,
      command => "cmd /c \"${base_folder}\\bin\\environment.bat\" && gem uninstall stomp -v=1.3.0",
    }
    exec { 'remove-stomp_1_3_1':
      path => $::path,
      command => "cmd /c \"${base_folder}\\bin\\environment.bat\" && gem uninstall stomp -v=1.3.1",
    }

			
		##############
	
    	file { "/etc/puppet-tmpfiles/mcollective-2.0.0.msi":
			path => "c:/puppet-tmpfiles/mcollective-2.0.0.msi",
    		ensure  => present,
    		source => "puppet:///ext-packages/mcollective/mcollective-2.0.0.msi"
    	}
    		
		Package["mcollective"] {
			ensure => installed,
			provider => msi,
			notify => undef,
			require => undef,
			source => 'c:\puppet-tmpfiles\mcollective-2.0.0.msi'
		}
		
		Service["mcollective"] {
			name => "mcollectived",
			ensure => running,
			enable => true,
    		require => Package["mcollective"],
		}
	}

}