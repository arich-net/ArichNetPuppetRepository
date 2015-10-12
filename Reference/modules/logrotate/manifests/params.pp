# Class: logrotate::params
#
# Operating systems:
#	:Working
#
# 	:Testing
#
# Parameters:
#
# Actions:
#
# Requires:
#
# Sample Usage:
#
class logrotate::params() {

  case $::operatingsystem {
    /(?i)(Debian|Ubuntu|Redhat)/: {
      $pkg     = 'logrotate'
      $confdir = '/etc/logrotate.d'
    }

    default: {
      fail "Module ${name} : Operating system not supported yet."
    }
  }
    
}