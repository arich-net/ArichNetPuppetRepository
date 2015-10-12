# Class: apt
#
# This module manages apt for ubuntu & debain
#
# Parameters:
#	$source_url = specify custom dist url, perhaps different country or local repo, defaults if unset
#	$include_src = Shall we use deb-src entries? true/false include_src => true,
#
# Actions:
#	1) Shall we use apt::source to control all the entries in sources.list ?
#
# Requires:
#
# Sample Usage:
#
# [Remember: No empty lines between comments and class definition]
class apt($source_url = undef, $include_src = false, $include_backports = false) {

# Ensure there is always a default mirror.
if $source_url == ""	{
#	$source_url_real = $::lsbdistid ? {
#     'ubuntu'  => 'http://archive.ubuntu.com/ubuntu',
#      'debian' => 'http://ftp.uk.debian.org/debian',
#      default  => undef,
#    }
    
    case $::lsbdistid {
    	'ubuntu': {
    		$source_url_real = 'http://archive.ubuntu.com/ubuntu'
    	}
    	'debian': {
			case $::lsbdistcodename {
				'lenny':{
					$source_url_real = 'http://archive.debian.org/debian'
					$source_security_url = 'http://archive.debian.org/debian-security'
				}
				default:{
					$source_url_real = 'http://ftp.uk.debian.org/debian'
					$source_security_url = 'http://security.debian.org'
				}	
			}
    	} 
    }
    
}else {
$source_url_real = $source_url	
}

# Ensure default repos
$repos_real = $::lsbdistid ? {
      'ubuntu'  => 'main restricted universe multiverse',
      'debian' => 'main',
      default  => undef,
    }

# Enable backports
if $include_backports {
	$backports_url = $::lsbdistid ? {
		'ubuntu' => 'http://archive.ubuntu.com/ubuntu',
		'debian' => 'http://backports.debian.org/debian-backports',
      default  => undef,
	}
}

  # apt support preferences.d since version >= 0.7.22
	case $::lsbdistcodename {
		/lucid|squeeze/ : {
			file {"/etc/apt/preferences":
				ensure => absent,
			}

			file {"/etc/apt/preferences.d":
				ensure => directory,
				owner => root,
				group => root,
				mode => 755,
				recurse => "true",
				purge => "true",
				force => "true",
			}
    	}
	}

	# ensure only files managed by puppet be present in this directory.
	file {"/etc/apt/sources.list":
		#ensure => $ensure,
		owner => root,
		group => root,
		mode => 644,
		content => template("apt/sources.list.erb"),
		before => Exec["apt-get_update"],
		notify => Exec["apt-get_update"],
	}
	
	# ensure only files managed by puppet be present in this directory.
	file { "/etc/apt/sources.list.d":
		ensure => directory,
		recurse => "true",
		purge => "true",
		force => "true",
		notify => Exec["apt-get_update"],
	}

#  apt::conf {"10periodic":
#    ensure => present,
#    source => "puppet:///apt/10periodic",
#  }

	exec { "apt-get_update":
		command => "apt-get update",
		refreshonly => true,
	}

}
