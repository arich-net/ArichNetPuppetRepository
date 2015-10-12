# Class: netbackup::params
#
# Params for netbackup class
#
# Parameters: setting provider and netbakcupclient
#   $provider
#   $netbackup_client_pkg
#   $add_routes
# Actions:
#
# Requires:
#
# Sample Usage:
#
# [Remember: No empty lines between comments and class definition]
class netbackup::params () {
  # Debian :: /netbackup_6.0MP5-2_all.deb
  # redhat :: netbackup-6.5.4-1.noarch.rpm
  # redhat/ES-5-x86/el-5-files/netbackup-6.5.4-1.noarch.rpm
  #
  
    case $::datacenter {
     /(?i)(Slough)/: { 
      $nbservers = $::netbackup_nbservers ? {
        '' => [ "eus3300001.oob.eu.verio.net", 
            "eus3300002.oob.eu.verio.net",
            "eus3300003.oob.eu.verio.net"],
        default => $::netbackup_nbservers,
        }
        
        include core::hosts::backupservers::slough
         
    }
    /(?i)(London)/: { 
      $nbservers = $::netbackup_nbservers ? {
        '' => [ "eus0000016.oob.eu.verio.net", 
            "eus0000217.oob.eu.verio.net"],
        default => $::netbackup_nbservers,
        }
        
        include core::hosts::backupservers::hex
         
    }
    /(?i)(Hemel)/: { 
      $nbservers = $::netbackup_nbservers ? {
        '' => [ "eus0000016.oob.eu.verio.net", 
            "eul4400503.oob.eu.verio.net",
            "eul4400504.oob.eu.verio.net"],
        default => $::netbackup_nbservers,
        }
          
        include core::hosts::backupservers::hemel
         
    }
    /(?i)(Frankfurt)/: { 
      $nbservers = $::netbackup_nbservers ? {
        '' => [ "eus0300005.oob.eu.verio.net", 
            "eus0300031.oob.eu.verio.net"],
        default => $::netbackup_nbservers,
        }
        
        include core::hosts::backupservers::frankfurt
         
    }
    /(?i)(Madrid)/: { 
      $nbservers = $::netbackup_nbservers ? {
        '' => [ "eus1900501.oob.eu.verio.net", 
            "eus1900500.oob.eu.verio.net"],
        default => $::netbackup_nbservers,
        }
        
        include core::hosts::backupservers::madrid
         
    }
    /(?i)(Paris3)/: { 
      $nbservers = $::netbackup_nbservers ? {
        '' => [ "eul2000512.oob.eu.verio.net"],
        default => $::netbackup_nbservers,
        }
        
        include core::hosts::backupservers::paris3
         
    }
    /(?i)(Paris2)/: { 
      $nbservers = $::netbackup_nbservers ? {
        '' => [ "eus2400002.oob.eu.verio.net", 
            "eus2400003.oob.eu.verio.net"],
        default => $::netbackup_nbservers,
        }
        
        include core::hosts::backupservers::paris2
         
    }
    default: {
        
    } 
  }

  case $::operatingsystem {

    /(?i)(redhat|centos)/ : {
      $provider = 'rpm'
      case $::lsbdistrelease { # last release first, old release default
        /6./     : { $netbackup_client_pkg = 'netbackup-7.5-1.x86_64.rpm' } # only 64 bit supported
        default : { $netbackup_client_pkg = 'netbackup-6.5.4-1.noarch.rpm' }
      } # lsbdistrelease
    } # redhat,centos

    /(?i)(ubuntu|debian)/ : {
      $provider = 'dpkg'
      case $::lsbdistcodename { # last release first, old release default
        'precise', 'wheezy', 'trusty' : { $netbackup_client_pkg = 'netbackup_7.5-2_amd64.deb' } # only 64 bit supported
        default             : { $netbackup_client_pkg = 'netbackup_6.5.4-2_all.deb' }
      }
    } # ubuntu, debian

    /(?i)(solaris)/          : {
      # Need to check this with facter on a sol box
      case $::architecture {
        'i386'   : { $netbackup_client_pkg = '' }
        'x86_64' : { $netbackup_client_pkg = '' }
      }
    }
    default            : {
      # Fail the catalog compliation becasue we're mean!
      fail("Module $module_name is not supported on os: $::operatingsystem, arch: $::architecture")
    }
  }
  # end case $operatingsystem
  
  # Adding routes for routed backup flag
  $add_routes = false
  
}
# End netbackup::params
