# Class: vmwaretools::params
#
# This module manages vmwaretools
#
# Parameters:
#
# Actions:
#
# Requires:
#
# Sample Usage:
#     class { 'vmwaretools': }
#
# [Remember: No empty lines between comments and class definition]
class vmwaretools::params {
  
  $esx_version = regsubst($::esxversion, '([0-9]\.[0-9]).*','\1')

  case $esx_version {
    /4.+/   : {
      $service_name = "vmware-tools"
      $service_path = undef
      $pkg_name = "vmware-open-vm-tools-nox"

      case $::operatingsystem {
        /(?i)(ubuntu)/ : {
          case $::lsbdistcodename {
            /(?i)(lucid)/ : {
              $uri = "http://packages.vmware.com/tools/esx/${esx_version}latest/ubuntu"
              $supported = true
            }
            default : {
              $supported = false
            }
          }
        }
        /(?i)(redhat|centos)/ : {
          case $::lsbdistrelease {
            /(6.)|(5.)/    : {
              $uri = "http://packages.vmware.com/tools/esx/${esx_version}latest/rhel${::lsbmajdistrelease}/${::architecture}"
              $supported = true
            }
            default : {
              $supported = false
            }
          }
        }
        default : {
          $supported = false
        }
      }
    }

    /5.+/   : {
      $pkg_name = "vmware-tools-esx-nox"
      $service_name = "vmware-tools-services"
      $service_path = "/etc/vmware-tools/init"

      case $::operatingsystem {
        /(?i)(ubuntu)/        : {
          case $::lsbdistcodename {
            /(?i)(trusty)/ : {
              /**
              case $::esxversion {
                /(5.5)|(5.1)/ : {
                  $supported = true
                  $uri = "http://packages.vmware.com/tools/esx/${esx_version}latest/ubuntu"
                }
                default : {
                  $supported = false
                }
              }
            *
            */
              $supported = false
            }
            default : {
              $supported = true
              $uri = "http://packages.vmware.com/tools/esx/${esx_version}latest/ubuntu"
            }
          }
        }
        /(?i)(redhat|centos)/ : {
          case $::lsbdistrelease {
            /6./ : {
              $supported = true

              case $::esxversion {
                /5.0/ : {
                  $uri = "http://packages.vmware.com/tools/esx/${esx_version}u3/rhel${::lsbmajdistrelease}/${::architecture}"
                }
                /5.1/ : {
                  $uri = "http://packages.vmware.com/tools/esx/${esx_version}u2/rhel${::lsbmajdistrelease}/${::architecture}"
                }
                /5.5/ : {
                  $uri = "http://packages.vmware.com/tools/esx/${esx_version}/rhel${::lsbmajdistrelease}/${::architecture}"
                }
              }
            }
            /7./ : {
              case $::esxversion {
                /5.1/ : {
                  $supported = true
                  $uri = "http://packages.vmware.com/tools/esx/${esx_version}u2/rhel${::lsbmajdistrelease}/${::architecture}"
                }
                /5.5/ : {
                  $supported = true
                  $uri = "http://packages.vmware.com/tools/esx/${esx_version}/rhel${::lsbmajdistrelease}/${::architecture}"
                }
                default : {
                  $supported = false
                }
              }
            }
            default : {
              $supported = false              
            }
          }
        }
        default               : {
          $supported = false
        }
      }
    }

    default : {
      # Rest not supported
      $supported = false
    }
  }

  ###########
  # OS specific variables and defaults
  case $::operatingsystem {
    'ubuntu'  : {
      case $::lsbdistcodename {
        /(?i)(precise)/ : { }
        default         : { }
      }
    }
    'debian'  : {

    }
    'redhat'  : {
      case $::lsbdistrelease {
        /6./    : { }
        default : { }
      }
    }
    'windows' : {
      case $::kernelmajversion {
        '5.2' : { # Server 2003
           }
        '6.0' : { # Server 2008
           }
        '6.1' : { # Server 2008 R2
           }
        '6.2' : { # Server 2012
           }
      }
    }
    # windows
    'freebsd' : {

    }
    default   : {
      # Not supported..
    }
  }

}

