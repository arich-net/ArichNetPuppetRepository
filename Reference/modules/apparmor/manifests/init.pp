# Class: apparmor
#
# Description of module
#
# Operating systems:
# :Working
#
# 	:Testing
#
# Parameters:
# List of all parameters used in this class
#
# Actions:
# List of any outstanding actions or notes for changes to be made.
#
# Requires:
# Class requirements
#
# Sample Usage:
# include apparmor
#
class apparmor () {
  
  file { '/etc/apparmor.d/disable/usr.sbin.dhcpd':
    ensure => 'link',
    target => '/etc/apparmor.d/usr.sbin.dhcpd',
  }

  file { '/etc/apparmor.d/disable/usr.sbin.rsyslogd':
    ensure => 'link',
    target => '/etc/apparmor.d/usr.sbin.rsyslogd',
  }

}