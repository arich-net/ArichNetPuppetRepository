# Class: vmwaretools
#
# Simple module to install vmwaretools, could expand further with params,
# to set package versioning or configuration.
#
#
# Operating systems:
# :Ubuntu
# 	10.04 : ESX 4.1+
# 	12.04 : ESX 5.0+
# : Redhat
#   6.0   : ESX 5.1+
# 	:Testing
#
# Parameters:
#
# Actions:
#
# Requires:
# Apt|Yum
#
# Sample Usage:
# include vmwaretools
#
class vmwaretools () inherits vmwaretools::params {
  
  if $vmwaretools::params::supported {
    case $::virtual {
      'vmware' : {
        include vmwaretools::repo::vmware

        # Ubuntu open-vm-tools as from 8.04 is not supported by vmware, plus it causes
        # issues with deployment customization.
        #
        package { 'vmware-tools':
          name    => $vmwaretools::params::pkg_name,
          ensure  => present,
          require => [Class["vmwaretools::repo::vmware"]],
        }

        # The vmware-tools-esx-nox package does not deploy a init script.
        # so for the time being we will statically point to the script.
        #
        service { "vmware-tools-services":
          name    => $vmwaretools::params::service_name,
          ensure  => running,
          # path => '/etc/vmware-tools/init',
          path    => $vmwaretools::params::service_path,
          require => [Package["vmware-tools"]],
        }

      }
      default  : {
        # Do nothing
      }

    }

  }
  else {
    # Fail because vmware tools is not supported for this OS and ESX version
    notify { "Module $module_name class $name is not supported on os: $::operatingsystem, arch: $::architecture": }
  }

}