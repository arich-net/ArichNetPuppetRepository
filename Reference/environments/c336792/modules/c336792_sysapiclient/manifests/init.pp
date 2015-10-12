# Class: sysapiclient
#
# sysapiclient, used internal integration between Splunk and SysAPI.
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
class c336792_sysapiclient {

	file { "/usr/local/sysapiclient":
		ensure  => directory,
		owner => root,
    group => root,
		recurse => true,
		purge => true,
		force => true, # Forces a removal if ensure => absent
		backup => false,
		source => "puppet:///modules/c336792_sysapiclient/sysapiclient/"
	}
	
  file { "/usr/local/sysapiclient/sysapiclient.rb":
    owner => root,
    group => root,
    mode => 0700,
    source => "puppet:///modules/c336792_sysapiclient/sysapiclient/sysapiclient.rb",
    require => File['/usr/local/sysapiclient'],
  }
  
  file { "/usr/local/sysapiclient/logs":
    ensure => directory,
    owner => root,
    group => root,
    mode => 0755,
    recurse => true,
    require => File['/usr/local/sysapiclient'],
  }
				     
}
