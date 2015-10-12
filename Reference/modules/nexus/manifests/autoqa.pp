# Class: nexus::autoqa
#
# Used for deploying nexus autoQA
# git-commmit      563c6bfa69e7d0d04e20cb30e091841b9b92eb0e
# git-branch       EN-26215-Automated_system_checks_v2
#
# Operating systems:
#
# Parameters:
#
# Actions:
#
# Requires:
#	include Apache
#	include nttedir
#
# Sample Usage:
#	
class nexus::autoqa() {

	package { 'libsoap-lite-perl': 
    	name   => "libsoap-lite-perl",
    	ensure => present,
	}
  
	file { "/usr/local/ntte/nexus":
		path => "/usr/local/ntte/nexus",
		ensure  => directory,
		owner => root,
    	group => root,
#	   	mode => 0755,
		recurse => true,
		purge => true,
		force => true, # Forces a removal if ensure => absent
		backup => false,
		source => "puppet:///modules/nexus",
		require => Class['nttedir'],
	}

	file { "/usr/local/ntte/nexus/checklists-sab/bin":
		path => "/usr/local/ntte/nexus/checklists-sab/bin",
		ensure => directory,
		owner => 'www-data',
    	group => 'www-data',
	   	mode => 0755,
	   	recurse => true,
	   	source => "puppet:///modules/nexus/checklists-sab/bin",
		require => File['/usr/local/ntte/nexus'],
	}
	
	file { "/usr/local/ntte/nexus/checklists-sab/logs":
		path => "/usr/local/ntte/nexus/checklists-sab/logs",
		ensure => directory,
		owner => 'www-data',
    	group => 'www-data',
	   	mode => 0755,
	   	recurse => true,
	   	source => "puppet:///modules/nexus/checklists-sab/logs",
		require => File['/usr/local/ntte/nexus'],
	}
	
	file { "/usr/local/ntte/nexus/checklists-sab/checklist_scripts":
		path => "/usr/local/ntte/nexus/checklists-sab/checklist_scripts",
		ensure => directory,
		owner => 'www-data',
    	group => 'www-data',
	   	mode => 0755,
	   	recurse => true,
	   	source => "puppet:///modules/nexus/checklists-sab/checklist_scripts",
		require => File["/usr/local/ntte/nexus"],
	}

	file { "/usr/local/ntte/nexus/checklists-sab/checklist_host_locks":
		path => "/usr/local/ntte/nexus/checklists-sab/checklist_host_locks",
		ensure => directory,
		owner => 'www-data',
    	group => 'www-data',
	   	mode => 0755,
	   	recurse => true,
	   	source => "puppet:///modules/nexus/checklists-sab/checklist_host_locks",
		require => File["/usr/local/ntte/nexus"],
	}


	apache::vhost { 'nexus-autoqa':
		template => 'autoqa-vhost.conf.erb',
    }
    
	@a2mod {
		'suexec' : ensure => present;
	}
        
    user { "nexus":
	 	ensure => present,
	 	uid => "1010",
	 	gid => "1010",
	 	password => '*',
	 	shell => '/bin/false',
	 	comment => "Nexus user, used for SAB access",
		}
		
	group { "nexus":
		ensure => present,
		gid => "1010",
	}
	
}