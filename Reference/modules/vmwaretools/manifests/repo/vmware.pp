# Class: vmwaretools::repo::vmware
#
# This class defines the apt sources/keys & preferences for the vmware repo
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
class vmwaretools::repo::vmware () inherits vmwaretools::params {
  case $::operatingsystem {
    /(?i)(Debian|Ubuntu)/ : {
      apt::source { 'vmware':
        ensure     => 'present',
        type       => 'deb',
        uri        => "${vmwaretools::params::uri}",
        dist       => "${::lsbdistcodename}",
        components => ['main']
      }

      apt::key { '66FD4949': ensure => 'present', }
    }

    /(?i)(Redhat|CentOS)/ : {
      yum::managed_yumrepo { 'vmware':
        descr          => 'VMWare tools',
        baseurl        => "${vmwaretools::params::uri}",
        enabled        => 1,
        gpgcheck       => 1,
        failovermethod => 'priority',
        gpgkey         => 'http://packages.vmware.com/tools/keys/VMWARE-PACKAGING-GPG-RSA-KEY.pub',
        priority       => 15,
      }
    }
    default               : {
      # fail 'Puppetlabs main repository only available for Ubuntu & Debian'
      notify { "Module $module_name class $name is not supported on os: $::operatingsystem, arch: $::architecture": }
    }
  }
}
