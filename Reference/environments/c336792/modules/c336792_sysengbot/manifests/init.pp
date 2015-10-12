# Class: c336792_sysengbot
#
# Sysengbot, a Jabber bot!
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
class c336792_sysengbot() {

  file { "/usr/local/sysengbot":
    ensure  => directory,
    owner => root,
    group => root,
    recurse => true,
    purge => true,
    force => true,
    backup => false,
    source => "puppet:///modules/c336792_sysengbot/sysengbot/"
  }
   
  file { "/usr/local/sysengbot/logs":
    ensure => directory,
    owner => 'root',
    group => 'root',
    mode => 0644,
    recurse => true,
    require => File['/usr/local/sysengbot'],
  }
  
  file { "/usr/local/sysengbot/var":
    ensure => directory,
    owner => 'root',
    group => 'root',
    mode => 0644,
    recurse => true,
    require => File['/usr/local/sysengbot'],
  }
             
}
